data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_role" "lab" {
  name = var.lab_role_name
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  effective_environment = terraform.workspace == "default" ? var.environment : terraform.workspace

  common_tags = {
    Project     = var.project_name
    Environment = local.effective_environment
    Workspace   = terraform.workspace
    ManagedBy   = "Terraform"
    Course      = "ARY1102"
    Case        = "FreshBox-SpA"
    Evaluation  = "EP2"
  }

  cluster_name = var.cluster_name
}
