resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = var.cluster_additional_security_group_ids
  }

  enabled_cluster_log_types = var.enable_cluster_logging ? [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ] : []

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

resource "aws_launch_template" "nodes" {
  name_prefix = "${var.project_name}-ng-"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_disk_size_gb
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.project_name}-node" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = "${var.project_name}-node-ebs" })
  }

  # SG del cluster (creado por EKS) + SG de nodos (ALB → pods, RDS)
  # Se setean en el node group via launch_template network interfaces?
  # Para managed node groups, security groups se pasan en launch_template.vpc_security_group_ids
  vpc_security_group_ids = concat(
    [aws_eks_cluster.this.vpc_config[0].cluster_security_group_id],
    var.node_security_group_ids
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "app" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  ami_type        = var.node_ami_type
  capacity_type   = "ON_DEMAND"
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  labels = {
    role = "app"
    tier = "private-app"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ng"
  })

  depends_on = [aws_eks_cluster.this]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.app]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.app]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.app]
}

resource "aws_eks_addon" "cloudwatch" {
  count = var.enable_cloudwatch_observability_addon ? 1 : 0

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.app]
}

data "tls_certificate" "oidc" {
  count = var.enable_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  count = var.enable_oidc_provider ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags            = merge(var.tags, { Name = "${var.cluster_name}-oidc" })
}
