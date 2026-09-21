# Backend remoto S3 (activar tras bootstrap en 00-terraform-state).
#
# 1) cd ../00-terraform-state && terraform apply
# 2) cp backend.hcl.example backend.hcl  # edita bucket/table
# 3) Descomenta el bloque abajo y ejecuta:
#      terraform init -reconfigure -backend-config=backend.hcl
#
# terraform {
#   backend "s3" {}
# }
