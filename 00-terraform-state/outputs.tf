output "state_bucket_name" {
  description = "Nombre del bucket S3 para el state de Terraform"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN del bucket S3 de state"
  value       = aws_s3_bucket.terraform_state.arn
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
    bucket         = "${aws_s3_bucket.terraform_state.id}"
    key            = "01-cloud-infrastructure/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
    encrypt        = true
  EOT
}

output "state_s3_path_hint" {
  description = "Ruta real en S3 con workspace clases (Terraform antepone env:/clases/)"
  value       = "s3://${aws_s3_bucket.terraform_state.id}/env:/clases/01-cloud-infrastructure/terraform.tfstate"
}
