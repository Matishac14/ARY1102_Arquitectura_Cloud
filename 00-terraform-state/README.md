# 00 — Bootstrap del state remoto (S3 + DynamoDB)

Crea el backend compartido para `01-cloud-infrastructure` y GitHub Actions.

> Este stack usa **state local** (huevo-gallina). No configures backend S3 aquí.

## Uso (diseño Terraform estándar)

```bash
export AWS_PROFILE=clases
cd 00-terraform-state
cp terraform.tfvars.example terraform.tfvars
# Edita state_bucket_name con tu Account ID

terraform init
terraform apply
terraform output
```

Recursos: bucket S3 + versioning + public access block + tabla DynamoDB de locks.

### Ruta del state (workspaces)

`key = "01-cloud-infrastructure/terraform.tfstate"` + workspace `clases` →

```text
s3://…/env:/clases/01-cloud-infrastructure/terraform.tfstate
```

No pongas `clases/` dentro del `key` (evita `env:/clases/clases/...`).

## Restricción Learner Lab (Object Lock) — no es un error de Terraform

En AWS Academy el **SCP de la organización** deniega:

`s3:GetBucketObjectLockConfiguration`

El provider AWS llama esa API al hacer **Read** del resource `aws_s3_bucket` (después del create o en cada refresh). Por eso aparece:

```text
AccessDenied: ... GetBucketObjectLockConfiguration ... explicit deny in a service control policy
```

| Qué implica | Detalle |
|-------------|---------|
| ¿Código TF mal? | No. El mismo `.tf` es válido fuera del lab. |
| ¿Se crea el bucket? | Suele **sí** crearse; falla el read posterior. |
| ¿DynamoDB? | Suele quedar OK en el state. |

### Qué hacer en el lab si ves ese 403

1. Consola S3 → confirma que existe `freshbox-ep1-tfstate-<ACCOUNT_ID>`.
2. Consola DynamoDB → confirma `freshbox-ep1-terraform-locks`.
3. Si ambos existen, **el bootstrap sirve para GitHub** (Variables `TF_STATE_BUCKET` / `TF_LOCK_TABLE`).
4. No hace falta re-aplicar `00` en cada sesión. Evita `terraform apply` repetido sobre el bucket (intentará recrear/refresh y volverá el 403).
5. Para plan local de este stack sin refrescar S3: `terraform plan -refresh=false`.

Si el bucket quedó en AWS pero **no** en el state local:

```bash
terraform import aws_s3_bucket.terraform_state freshbox-ep1-tfstate-<ACCOUNT_ID>
```

El import también hace Read; en el lab puede fallar por el mismo SCP. En ese caso deja el bucket en AWS (ya usable) y el state local con la tabla DynamoDB; documenta los nombres en GitHub Variables.

## GitHub

Tras tener bucket + tabla, Environment `clases` → ver [../.github/README.md](../.github/README.md).
