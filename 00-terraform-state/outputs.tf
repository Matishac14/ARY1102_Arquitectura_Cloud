output "state_bucket_name" {
  description = "Nombre del bucket S3 (creado con bootstrap-s3.sh, no con TF)"
  value       = var.state_bucket_name
}

output "state_bucket_arn" {
  description = "ARN del bucket S3 de state"
  value       = "arn:aws:s3:::${var.state_bucket_name}"
}

output "dynamodb_lock_table" {
  description = "Tabla DynamoDB para state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "aws_region" {
  value = var.aws_region
}

output "backend_hcl_example" {
  description = "Contenido sugerido para 01-cloud-infrastructure/backend.hcl"
  value       = <<-EOT
    bucket         = "${var.state_bucket_name}"
    key            = "01-cloud-infrastructure/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
    encrypt        = true
  EOT
}

output "state_s3_path_hint" {
  description = "Ruta real en S3 con workspace clases"
  value       = "s3://${var.state_bucket_name}/env:/clases/01-cloud-infrastructure/terraform.tfstate"
}
