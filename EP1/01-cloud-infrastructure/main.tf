module "network" {
  source = "./modules/network"

  project_name              = var.project_name
  vpc_cidr                  = var.vpc_cidr
  availability_zones        = local.azs
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
  tags                      = local.common_tags
}

module "routing" {
  source = "./modules/routing"

  project_name            = var.project_name
  vpc_id                  = module.network.vpc_id
  internet_gateway_id     = module.network.internet_gateway_id
  public_subnet_ids       = module.network.public_subnet_ids
  private_app_subnet_ids  = module.network.private_app_subnet_ids
  private_data_subnet_ids = module.network.private_data_subnet_ids
  tags                    = local.common_tags
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  tags         = local.common_tags
}

module "container_registries" {
  source = "./modules/container-registries"

  project_name     = var.project_name
  repository_names = var.ecr_repository_names
  tags             = local.common_tags
}

module "load_balancer" {
  source = "./modules/load-balancer"

  project_name          = var.project_name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  tags                  = local.common_tags
}

module "database_server" {
  source = "./modules/database-server"

  project_name          = var.project_name
  ami_id                = data.aws_ami.amazon_linux_2023_arm.id
  instance_type         = var.instance_type
  subnet_id             = module.network.private_data_subnet_ids[0]
  security_group_id     = module.security_groups.data_security_group_id
  instance_profile_name = var.instance_profile_name
  key_name              = var.key_name
  root_volume_size_gb   = var.root_volume_size_gb
  db_name               = var.db_name
  db_user               = var.db_user
  db_password           = var.db_password
  db_root_password      = var.db_root_password
  init_sql              = local.init_sql
  backup_role_arn       = data.aws_iam_role.lab.arn
  backup_retention_days = var.backup_retention_days
  tags                  = local.common_tags

  depends_on = [module.routing]
}

module "application_autoscaling" {
  source = "./modules/application-autoscaling"

  project_name          = var.project_name
  ami_id                = data.aws_ami.amazon_linux_2023_arm.id
  instance_type         = var.instance_type
  subnet_ids            = module.network.private_app_subnet_ids
  security_group_id     = module.security_groups.app_security_group_id
  instance_profile_name = var.instance_profile_name
  key_name              = var.key_name
  target_group_arn      = module.load_balancer.target_group_arn
  aws_region            = var.aws_region
  aws_account_id        = data.aws_caller_identity.current.account_id
  db_host               = module.database_server.private_ip
  db_name               = var.db_name
  db_user               = var.db_user
  db_password           = var.db_password
  root_volume_size_gb   = var.root_volume_size_gb
  asg_min_size          = var.asg_min_size
  asg_max_size          = var.asg_max_size
  asg_desired_capacity  = var.asg_desired_capacity
  tags                  = local.common_tags

  depends_on = [module.routing, module.container_registries, module.database_server]
}
