variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Nombre globalmente único del bucket S3"
}

variable "lock_table_name" {
  type        = string
  description = "Nombre de la tabla DynamoDB para locking del state"
  default     = "freshbox-ep1-terraform-locks"
}