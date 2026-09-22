# 00 — Bootstrap del state remoto (S3 + DynamoDB)

Crea el backend compartido para `01-cloud-infrastructure` y GitHub Actions.

> Este stack usa **state local** (huevo-gallina). No configures backend S3 aquí.

## Learner Lab

- Región: `us-east-1`
- Bucket **globalmente único** (incluye Account ID)
- Stack **minimo**: bucket + versioning + public access block + DynamoDB locks
- Si `terraform plan` falla con `GetBucketObjectLockConfiguration` / SCP deny:
  el bucket ya existe; usa `terraform plan -refresh=false` o no re-apliques `00`.

## Uso (una vez por cuenta)

```bash
export AWS_PROFILE=clases
cd 00-terraform-state
cp terraform.tfvars.example terraform.tfvars
# Edita state_bucket_name con tu Account ID

terraform init
terraform apply
terraform output backend_hcl_example
terraform output state_s3_path_hint
```

Copia el output a `../01-cloud-infrastructure/backend.hcl`.

### Ruta del state (workspaces)

Con `key = "01-cloud-infrastructure/terraform.tfstate"` y workspace `clases`:

```text
s3://freshbox-ep1-tfstate-<ACCOUNT>/env:/clases/01-cloud-infrastructure/terraform.tfstate
```

**No** pongas `clases/` dentro del `key` (si no, queda `env:/clases/clases/...`).

```bash
cd ../01-cloud-infrastructure
terraform init -reconfigure -backend-config=backend.hcl
terraform workspace select clases || terraform workspace new clases
```

## GitHub

## Si el state local de `00` aún lista recursos viejos

Tras simplificar el stack, limpia referencias huérfanas (no borra el bucket):

```bash
cd 00-terraform-state
terraform state rm aws_s3_bucket_server_side_encryption_configuration.terraform_state 2>/dev/null || true
terraform state rm aws_s3_bucket_ownership_controls.terraform_state 2>/dev/null || true
terraform state rm aws_s3_bucket_policy.terraform_state 2>/dev/null || true
terraform plan -refresh=false
```
