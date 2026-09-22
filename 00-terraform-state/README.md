# 00 — Bootstrap del state remoto (S3 + DynamoDB)

Crea el backend compartido para `01-cloud-infrastructure` y GitHub Actions.

> Este stack usa **state local** (huevo-gallina). No configures backend S3 aquí.

## Learner Lab

- Región: `us-east-1`
- Bucket **globalmente único** (incluye Account ID)
- No crea roles IAM
- Si `terraform plan` falla con `GetBucketObjectLockConfiguration` / SCP deny:
  el bucket ya existe; usa `terraform plan -refresh=false` o no re-apliques `00`.
  GitHub solo necesita los nombres del bucket y la tabla.

## Uso (una vez por cuenta / si se perdió el bucket)

```bash
export AWS_PROFILE=clases
cd 00-terraform-state
cp terraform.tfvars.example terraform.tfvars
# Edita state_bucket_name con tu Account ID

terraform init
terraform apply
terraform output backend_hcl_example
```

Copia el output a `../01-cloud-infrastructure/backend.hcl` y luego:

```bash
cd ../01-cloud-infrastructure
terraform init -reconfigure -backend-config=backend.hcl
terraform workspace select clases || terraform workspace new clases
```

## GitHub

Tras el apply, configura el Environment `clases` (ver [../.github/README.md](../.github/README.md)):

| Tipo | Nombre | Valor |
|------|--------|-------|
| Variable | `AWS_REGION` | `us-east-1` |
| Variable | `TF_STATE_BUCKET` | output `state_bucket_name` |
| Variable | `TF_LOCK_TABLE` | output `dynamodb_lock_table` |
| Secret (env `clases`) | `AWS_ACCESS_KEY_ID` | del lab |
| Secret (env `clases`) | `AWS_SECRET_ACCESS_KEY` | del lab |
| Secret (env `clases`) | `AWS_SESSION_TOKEN` | del lab (caduca) |
