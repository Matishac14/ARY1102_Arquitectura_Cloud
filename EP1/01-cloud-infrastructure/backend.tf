# Backend remoto S3 (activado tras bootstrap en 00-terraform-state).
# Config: backend.hcl (gitignored). Init:
#   terraform init -reconfigure -backend-config=backend.hcl
terraform {
  backend "s3" {}
}
