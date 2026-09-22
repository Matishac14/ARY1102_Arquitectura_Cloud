provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "freshbox-ep1"
      Environment = "clases"
      ManagedBy   = "Terraform"
      Course      = "ARY1102"
      Purpose     = "terraform-remote-state"
    }
  }
}

# ---------------------------------------------------------------------------
# Learner Lab / AWS Academy:
# El resource aws_s3_bucket SIEMPRE llama s3:GetBucketObjectLockConfiguration
# en el Read del provider. El SCP del lab lo deniega (403) → apply/plan fallan
# aunque el bucket se haya creado bien.
#
# Por eso el bucket S3 se crea con AWS CLI (./bootstrap-s3.sh), no con Terraform.
# Aquí solo gestionamos el lock table (DynamoDB).
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.lock_table_name
  }
}
