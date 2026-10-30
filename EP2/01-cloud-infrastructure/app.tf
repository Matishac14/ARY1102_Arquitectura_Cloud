# =============================================================================
# Despliegue de aplicación en el mismo `terraform apply`
# (ECR push → espera nodos → ALB Controller → K8s → init.sql)
# =============================================================================

locals {
  app_path   = "${path.module}/../desarrolloapp"
  account_id = data.aws_caller_identity.current.account_id
  ecr_base   = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  image_tag  = "latest"
  k8s_ns     = "freshbox"
  backend_svcs = {
    get-products = {
      port  = 3001
      image = "freshbox-get-products"
    }
    create-product = {
      port  = 3002
      image = "freshbox-create-product"
    }
    update-product = {
      port  = 3003
      image = "freshbox-update-product"
    }
    delete-product = {
      port  = 3004
      image = "freshbox-delete-product"
    }
  }
  source_fingerprint = sha256(join("", concat(
    [for f in fileset(local.app_path, "microservicioEKSFrontend/**") : filesha256("${local.app_path}/${f}")],
    [for f in fileset(local.app_path, "microserviciosEKSBackend/**") : filesha256("${local.app_path}/${f}")],
    [filesha256("${local.app_path}/scripts/ecr-push.sh")],
  )))
}

# --- 1) Build & push imágenes ARM64 a ECR ---
resource "null_resource" "ecr_push" {
  count = var.deploy_application ? 1 : 0

  triggers = {
    source_hash = local.source_fingerprint
    ecr_urls    = join(",", values(module.ecr.repository_urls))
  }

  depends_on = [module.ecr]

  provisioner "local-exec" {
    working_dir = local.app_path
    # No exportar AWS_PROFILE vacío: el CLI interpreta profile "" y falla
    command = <<-EOT
      set -euo pipefail
      export AWS_REGION="${var.aws_region}"
      if [ -n "${var.aws_profile}" ]; then export AWS_PROFILE="${var.aws_profile}"; fi
      bash ./scripts/ecr-push.sh
    EOT
  }
}

# --- 2) Esperar nodos Ready antes de Helm/K8s ---
resource "null_resource" "wait_for_nodes" {
  count = var.deploy_application ? 1 : 0

  triggers = {
    cluster = module.eks.cluster_name
    ng      = module.eks.node_group_name
  }

  depends_on = [module.eks, null_resource.ecr_push]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      aws eks update-kubeconfig --region "${var.aws_region}" --name "${module.eks.cluster_name}" ${var.aws_profile != "" ? "--profile ${var.aws_profile}" : ""}
      echo "Esperando nodos Ready..."
      for i in $(seq 1 60); do
        READY=$(kubectl get nodes --no-headers 2>/dev/null | awk '$2=="Ready"' | wc -l | tr -d ' ')
        if [ "$${READY:-0}" -ge 2 ]; then
          echo "Nodos Ready: $READY"
          exit 0
        fi
        sleep 15
      done
      echo "Timeout esperando nodos" >&2
      kubectl get nodes || true
      exit 1
    EOT
  }
}

# --- 3) CRDs + AWS Load Balancer Controller (Helm) ---
resource "null_resource" "alb_controller_crds" {
  count = var.deploy_application ? 1 : 0

  triggers = {
    cluster = module.eks.cluster_name
  }

  depends_on = [null_resource.wait_for_nodes]

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml"
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.deploy_application ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "region"
    value = var.aws_region
  }
  set {
    name  = "vpcId"
    value = module.network.vpc_id
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "enableShield"
    value = "false"
  }
  set {
    name  = "enableWaf"
    value = "false"
  }
  set {
    name  = "enableWafv2"
    value = "false"
  }
  set {
    name  = "replicaCount"
    value = "1"
  }

  depends_on = [null_resource.alb_controller_crds]
}

# Metrics Server (requerido por HPA) — vía Helm, compatible con Academy
resource "helm_release" "metrics_server" {
  count = var.deploy_application ? 1 : 0

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  depends_on = [null_resource.wait_for_nodes]
}

# --- 4) Namespace / Config / Secret ---
resource "kubernetes_namespace_v1" "freshbox" {
  count = var.deploy_application ? 1 : 0

  metadata {
    name = local.k8s_ns
    labels = {
      app = "freshbox"
    }
  }

  depends_on = [null_resource.wait_for_nodes]
}

resource "kubernetes_config_map_v1" "freshbox" {
  count = var.deploy_application ? 1 : 0

  metadata {
    name      = "freshbox-config"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
  }

  data = {
    DB_HOST = module.rds.address
    DB_NAME = var.db_name
    DB_PORT = tostring(module.rds.port)
  }
}

resource "kubernetes_secret_v1" "freshbox" {
  count = var.deploy_application ? 1 : 0

  metadata {
    name      = "freshbox-secret"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
  }

  data = {
    DB_USER = var.db_username
    DB_PASS = var.db_password
  }

  type = "Opaque"
}

# --- 5) Frontend ---
resource "kubernetes_deployment_v1" "frontend" {
  count = var.deploy_application ? 1 : 0

  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
    labels    = { app = "frontend" }
  }

  spec {
    # t4g.small ≈ 11 pods/nodo; con addons CW/ALB conviene 1 réplica base
    replicas = 1
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata {
        labels = { app = "frontend" }
      }
      spec {
        container {
          name  = "frontend"
          image = "${local.ecr_base}/freshbox-frontend:${local.image_tag}"
          port {
            container_port = 80
          }
          resources {
            requests = { cpu = "100m", memory = "128Mi" }
            limits   = { cpu = "250m", memory = "256Mi" }
          }
        }
      }
    }
  }

  depends_on = [null_resource.ecr_push, helm_release.aws_load_balancer_controller]
}

resource "kubernetes_service_v1" "frontend" {
  count = var.deploy_application ? 1 : 0

  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
  }
  spec {
    selector = { app = "frontend" }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

# --- 6) Backends CRUD ---
resource "kubernetes_deployment_v1" "backend" {
  for_each = var.deploy_application ? local.backend_svcs : {}

  metadata {
    name      = each.key
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
    labels    = { app = each.key }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = each.key }
    }
    template {
      metadata {
        labels = { app = each.key }
      }
      spec {
        container {
          name  = each.key
          image = "${local.ecr_base}/${each.value.image}:${local.image_tag}"
          port {
            container_port = each.value.port
          }
          env {
            name  = "PORT"
            value = tostring(each.value.port)
          }
          env {
            name = "DB_HOST"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map_v1.freshbox[0].metadata[0].name
                key  = "DB_HOST"
              }
            }
          }
          env {
            name = "DB_NAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map_v1.freshbox[0].metadata[0].name
                key  = "DB_NAME"
              }
            }
          }
          env {
            name = "DB_PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map_v1.freshbox[0].metadata[0].name
                key  = "DB_PORT"
              }
            }
          }
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.freshbox[0].metadata[0].name
                key  = "DB_USER"
              }
            }
          }
          env {
            name = "DB_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.freshbox[0].metadata[0].name
                key  = "DB_PASS"
              }
            }
          }
          resources {
            requests = { cpu = "100m", memory = "128Mi" }
            limits   = { cpu = "250m", memory = "256Mi" }
          }
        }
      }
    }
  }

  depends_on = [null_resource.ecr_push, kubernetes_config_map_v1.freshbox, kubernetes_secret_v1.freshbox]
}

resource "kubernetes_service_v1" "backend" {
  for_each = var.deploy_application ? local.backend_svcs : {}

  metadata {
    name      = each.key
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
  }
  spec {
    selector = { app = each.key }
    port {
      port        = each.value.port
      target_port = each.value.port
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "backend" {
  for_each = var.deploy_application ? local.backend_svcs : {}

  metadata {
    name      = "${each.key}-hpa"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
  }
  spec {
    min_replicas = 1
    max_replicas = 4
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.backend[each.key].metadata[0].name
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }
  }
}

# --- 7) Ingress (ALB) — todo al frontend; nginx enruta CRUD ---
resource "kubernetes_ingress_v1" "freshbox" {
  count = var.deploy_application ? 1 : 0

  wait_for_load_balancer = true

  metadata {
    name      = "freshbox-ingress"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                                   = "alb"
      "alb.ingress.kubernetes.io/scheme"                              = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"                         = "ip"
      "alb.ingress.kubernetes.io/listen-ports"                        = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/security-groups"                     = module.security_groups.alb_security_group_id
      "alb.ingress.kubernetes.io/manage-backend-security-group-rules" = "true"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.frontend[0].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.aws_load_balancer_controller,
    kubernetes_deployment_v1.frontend,
    kubernetes_deployment_v1.backend,
  ]
}

# --- 8) init.sql vía Job en el cluster (sin mysql client local) ---
resource "kubernetes_config_map_v1" "init_sql" {
  count = var.deploy_application ? 1 : 0

  metadata {
    name      = "freshbox-init-sql"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
  }

  data = {
    "init.sql" = file("${local.app_path}/init.sql")
  }
}

resource "kubernetes_job_v1" "bootstrap_rds" {
  count = var.deploy_application ? 1 : 0

  metadata {
    name      = "freshbox-bootstrap-rds"
    namespace = kubernetes_namespace_v1.freshbox[0].metadata[0].name
  }

  spec {
    backoff_limit = 4
    template {
      metadata {
        labels = { app = "bootstrap-rds" }
      }
      spec {
        restart_policy = "OnFailure"
        container {
          name  = "mysql-client"
          image = "mysql:8.0"
          command = [
            "sh", "-c",
            "mysql -h \"$DB_HOST\" -P \"$DB_PORT\" -u \"$DB_USER\" -p\"$DB_PASS\" < /sql/init.sql && echo BOOTSTRAP_OK"
          ]
          env {
            name = "DB_HOST"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map_v1.freshbox[0].metadata[0].name
                key  = "DB_HOST"
              }
            }
          }
          env {
            name = "DB_PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map_v1.freshbox[0].metadata[0].name
                key  = "DB_PORT"
              }
            }
          }
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.freshbox[0].metadata[0].name
                key  = "DB_USER"
              }
            }
          }
          env {
            name = "DB_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.freshbox[0].metadata[0].name
                key  = "DB_PASS"
              }
            }
          }
          volume_mount {
            name       = "sql"
            mount_path = "/sql"
          }
        }
        volume {
          name = "sql"
          config_map {
            name = kubernetes_config_map_v1.init_sql[0].metadata[0].name
          }
        }
      }
    }
  }

  wait_for_completion = true
  timeouts {
    create = "10m"
  }

  depends_on = [
    module.rds,
    kubernetes_deployment_v1.backend,
  ]
}
