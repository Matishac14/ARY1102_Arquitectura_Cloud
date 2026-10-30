data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_iam_role" "lab" {
  name = var.lab_role_name
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # El workspace activo (ej. clases) identifica el entorno en tags y nombres.
  effective_environment = terraform.workspace == "default" ? var.environment : terraform.workspace

  common_tags = {
    Project     = var.project_name
    Environment = local.effective_environment
    Workspace   = terraform.workspace
    ManagedBy   = "Terraform"
    Course      = "ARY1102"
    Case        = "FreshBox-SpA"
  }

  init_sql = file("${path.module}/../init.sql")
}
