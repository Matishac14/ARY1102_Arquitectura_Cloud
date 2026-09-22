# 00 — Bootstrap del state remoto (S3 + DynamoDB)

> State **local** (huevo-gallina). No configures backend S3 aquí.

## Por qué el bucket NO va en Terraform

El resource `aws_s3_bucket` del provider AWS, en cada create/read, llama a:

`s3:GetBucketObjectLockConfiguration`

En AWS Academy Learner Lab esa acción tiene **Deny explícito en el SCP** →
`terraform apply` falla con 403 **aunque el bucket se haya creado bien**.
No se soluciona quitando attributes del `.tf`: el provider siempre hace esa lectura.

**Solución:** crear el bucket con AWS CLI (`bootstrap-s3.sh`) y dejar en Terraform solo DynamoDB.

## Uso (una vez)

```bash
export AWS_PROFILE=clases
cd 00-terraform-state
cp terraform.tfvars.example terraform.tfvars
# Edita state_bucket_name = "freshbox-ep1-tfstate-<ACCOUNT_ID>"

chmod +x bootstrap-s3.sh
./bootstrap-s3.sh

terraform init
terraform apply   # solo crea/actualiza la tabla de locks
terraform output
```

Si el bucket y la tabla **ya existen** (tu caso), no hace falta recrearlos:

```bash
./bootstrap-s3.sh          # idempotente (solo asegura versioning/PAB)
terraform apply            # asegura DynamoDB en el state local
```

### Ruta del state (workspaces)

`key = "01-cloud-infrastructure/terraform.tfstate"` + workspace `clases` →

```text
s3://…/env:/clases/01-cloud-infrastructure/terraform.tfstate
```

## GitHub

Variables: `TF_STATE_BUCKET`, `TF_LOCK_TABLE` (ver [../.github/README.md](../.github/README.md)).
