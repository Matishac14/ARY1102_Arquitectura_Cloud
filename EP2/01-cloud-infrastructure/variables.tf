variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "Perfil AWS CLI. Vacio = env/default chain (Academy)."
  default     = ""
}

variable "project_name" {
  type    = string
  default = "freshbox-ep2"
}

variable "environment" {
  type    = string
  default = "clases"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR distinto de EP1 (10.0.0.0/22) para coexistir en el lab"
  default     = "10.20.0.0/22"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.0.0/25", "10.20.0.128/25"]
}

variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/25", "10.20.1.128/25"]
}

variable "private_data_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.2.0/25", "10.20.2.128/25"]
}

variable "lab_role_name" {
  type        = string
  description = "Rol IAM precreado Learner Lab (cluster + nodes EKS). No crear roles IAM."
  default     = "LabRole"
}

variable "cluster_name" {
  type    = string
  default = "freshbox-cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Version EKS soportada para CreateCluster (1.29 ya no se puede crear en us-east-1)"
  default     = "1.34"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t4g.small"]
}

variable "node_ami_type" {
  type        = string
  description = "AMI ARM64 para t4g (AL2023)"
  default     = "AL2023_ARM_64_STANDARD"
}

variable "node_disk_size_gb" {
  type    = number
  default = 30
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "db_identifier" {
  type    = string
  default = "freshbox-ep2-mysql"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.small"
}

variable "db_engine_version" {
  type    = string
  default = "8.0"
}

variable "db_name" {
  type    = string
  default = "freshbox"
}

variable "db_username" {
  type    = string
  default = "alumno"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "alumno123"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_backup_retention_days" {
  type    = number
  default = 7
}

variable "ecr_repository_names" {
  type = list(string)
  default = [
    "freshbox-frontend",
    "freshbox-get-products",
    "freshbox-create-product",
    "freshbox-update-product",
    "freshbox-delete-product"
  ]
}

variable "enable_cluster_logging" {
  type    = bool
  default = true
}

variable "enable_cloudwatch_observability_addon" {
  type        = bool
  description = "Addon amazon-cloudwatch-observability (Container Insights). Desactivar si el lab lo bloquea."
  default     = true
}

variable "enable_oidc_provider" {
  type        = bool
  description = "Crear OIDC provider EKS (IRSA). Desactivar si el lab bloquea iam:CreateOpenIDConnectProvider."
  default     = false
}

variable "deploy_application" {
  type        = bool
  description = "false = solo infra AWS. true = tambien ECR push + ALB Controller + K8s + init.sql"
  default     = false
}
