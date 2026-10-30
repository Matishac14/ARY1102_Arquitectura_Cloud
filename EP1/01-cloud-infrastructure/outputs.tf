output "terraform_workspace" {
  description = "Workspace Terraform activo (debe ser 'clases' en el lab)"
  value       = terraform.workspace
}

output "environment" {
  value = local.effective_environment
}

output "vpc_id" {
  value = module.network.vpc_id
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

output "alb_dns_name" {
  description = "URL publica de la aplicacion FreshBox"
  value       = module.load_balancer.alb_dns_name
}

output "alb_url" {
  value = "http://${module.load_balancer.alb_dns_name}"
}

output "mysql_private_ip" {
  description = "IP privada del EC2 MySQL (capa Data)"
  value       = module.database_server.private_ip
}

output "mysql_instance_id" {
  value = module.database_server.instance_id
}

output "asg_name" {
  value = module.application_autoscaling.asg_name
}

output "ecr_repository_urls" {
  value = module.container_registries.repository_urls
}

output "security_group_ids" {
  value = {
    alb  = module.security_groups.alb_security_group_id
    app  = module.security_groups.app_security_group_id
    data = module.security_groups.data_security_group_id
  }
}

output "availability_zones" {
  value = local.azs
}

output "backup_vault_name" {
  value = module.database_server.backup_vault_name
}
