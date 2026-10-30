output "terraform_workspace" {
  value = terraform.workspace
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.network.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  value = module.network.private_data_subnet_ids
}

output "nat_gateway_id" {
  value = module.routing.nat_gateway_id
}

output "security_group_ids" {
  value = {
    alb = module.security_groups.alb_security_group_id
    eks = module.security_groups.eks_node_security_group_id
    rds = module.security_groups.rds_security_group_id
  }
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "rds_endpoint" {
  description = "Endpoint RDS (usar en ConfigMap DB_HOST, sin :3306)"
  value       = module.rds.address
}

output "rds_port" {
  value = module.rds.port
}

output "rds_instance_id" {
  value = module.rds.db_instance_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "eks_oidc_issuer_url" {
  value = module.eks.oidc_issuer_url
}

output "configure_kubectl" {
  description = "Comando para apuntar kubectl al cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "alb_security_group_id" {
  description = "Anotar en Ingress: alb.ingress.kubernetes.io/security-groups"
  value       = module.security_groups.alb_security_group_id
}

output "availability_zones" {
  value = local.azs
}

output "app_url" {
  description = "URL publica FreshBox. El ALB lo crea el AWS Load Balancer Controller al aplicar el Ingress (solo con deploy_application=true)."
  value = (
    var.deploy_application
    ? try(
      "http://${kubernetes_ingress_v1.freshbox[0].status[0].load_balancer[0].ingress[0].hostname}",
      "pendiente (kubectl -n freshbox get ingress — el Controller aun esta provisionando el ALB)"
    )
    : "aún no hay ALB: deploy_application=false. El DNS aparece al aplicar Ingress (poner true y re-apply)."
  )
}

output "next_steps" {
  value = join("\n", compact([
    var.deploy_application ? "Infra + app desplegadas." : "Infra lista (VPC/EKS/RDS/ECR/SG-ALB). Todavia NO hay Load Balancer.",
    var.deploy_application ? null : "En EP2 el ALB no es un aws_lb de Terraform: lo crea el Ingress via AWS Load Balancer Controller.",
    var.deploy_application ? null : "Para DNS publico: deploy_application=true → terraform apply → terraform output -raw app_url",
    var.deploy_application ? "1) Abrir: terraform output -raw app_url" : null,
    "kubectl: ${format("aws eks update-kubeconfig --region %s --name %s", var.aws_region, module.eks.cluster_name)}",
    var.deploy_application ? "3) Validar CRUD en el navegador (GET/POST/PUT/DELETE productos)" : null,
  ]))
}
