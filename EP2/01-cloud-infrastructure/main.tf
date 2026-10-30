module "network" {
  source = "./modules/network"

  project_name              = var.project_name
  cluster_name              = local.cluster_name
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

module "ecr" {
  source = "./modules/ecr"

  project_name     = var.project_name
  repository_names = var.ecr_repository_names
  tags             = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  project_name            = var.project_name
  identifier              = var.db_identifier
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = var.db_allocated_storage
  backup_retention_period = var.db_backup_retention_days
  subnet_ids              = module.network.private_data_subnet_ids
  vpc_security_group_ids  = [module.security_groups.rds_security_group_id]
  tags                    = local.common_tags

  depends_on = [module.routing]
}

module "eks" {
  source = "./modules/eks"

  project_name                          = var.project_name
  cluster_name                          = local.cluster_name
  kubernetes_version                    = var.kubernetes_version
  cluster_role_arn                      = data.aws_iam_role.lab.arn
  node_role_arn                         = data.aws_iam_role.lab.arn
  private_subnet_ids                    = module.network.private_app_subnet_ids
  public_subnet_ids                     = module.network.public_subnet_ids
  cluster_additional_security_group_ids = [module.security_groups.eks_cluster_security_group_id]
  node_security_group_ids               = [module.security_groups.eks_node_security_group_id]
  node_instance_types                   = var.node_instance_types
  node_ami_type                         = var.node_ami_type
  node_disk_size_gb                     = var.node_disk_size_gb
  node_min_size                         = var.node_min_size
  node_max_size                         = var.node_max_size
  node_desired_size                     = var.node_desired_size
  enable_cluster_logging                = var.enable_cluster_logging
  enable_cloudwatch_observability_addon = var.enable_cloudwatch_observability_addon
  enable_oidc_provider                  = var.enable_oidc_provider
  tags                                  = local.common_tags

  depends_on = [module.routing]
}
