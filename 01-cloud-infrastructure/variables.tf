variable "aws_region" {
  type        = string
  description = "Region AWS (Learner Lab: us-east-1 o us-west-2)"
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "Perfil AWS CLI local (ej. clases). Vacio = env/Secrets (requerido en GitHub Actions)."
  default     = ""
}

variable "project_name" {
  type        = string
  description = "Prefijo de nombres de recursos"
  default     = "freshbox-ep1"
}

variable "environment" {
  type        = string
  description = "Nombre logico del entorno. Con workspace != default se usa terraform.workspace (ej. clases)."
  default     = "clases"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR de la VPC (/22 segun enunciado EP1)"
  default     = "10.0.0.0/22"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/25", "10.0.0.128/25"]
}

variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/25", "10.0.1.128/25"]
}

variable "private_data_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/25", "10.0.2.128/25"]
}

variable "instance_type" {
  type        = string
  description = "Tipo EC2 permitido en Learner Lab (t4g.small = Graviton small)"
  default     = "t4g.small"
}

variable "key_name" {
  type        = string
  description = "Key pair existente (vockey en us-east-1 del Learner Lab)"
  default     = "vockey"
}

variable "instance_profile_name" {
  type        = string
  description = "Instance profile precreado del lab (NO crear roles IAM)"
  default     = "LabInstanceProfile"
}

variable "lab_role_name" {
  type        = string
  description = "Rol IAM precreado del Learner Lab"
  default     = "LabRole"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 4
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "root_volume_size_gb" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "freshbox"
}

variable "db_user" {
  type    = string
  default = "alumno"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "alumno123"
}

variable "db_root_password" {
  type      = string
  sensitive = true
  default   = "root123"
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

variable "backup_retention_days" {
  type    = number
  default = 7
}
