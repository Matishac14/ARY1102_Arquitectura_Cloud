# GitHub Actions — FreshBox EP1

## Workflows

| Workflow | Trigger | Proposito |
|----------|---------|-----------|
| `terraform-ci.yml` | PR / push | `fmt` + `validate` (sin credenciales AWS) |
| `deploy-lab.yml` | **solo manual** (`workflow_dispatch`) | plan / apply / full-deploy / destroy en el lab |

## Orden correcto

1. **Local (una vez):** bootstrap `00-terraform-state` → crea S3 + DynamoDB  
2. **GitHub:** Environment `clases` con Variables + Secrets  
3. **Actions:** `plan` → luego `full-deploy`

## Configurar Environment `clases`

1. Repo → **Settings** → **Environments** → **New environment** → nombre: `clases`
2. (Opcional) Required reviewers / Wait timer
3. **Environment secrets**

| Secret | Origen |
|--------|--------|
| `AWS_ACCESS_KEY_ID` | Lab → AWS Details |
| `AWS_SECRET_ACCESS_KEY` | Lab → AWS Details |
| `AWS_SESSION_TOKEN` | Lab → AWS Details (**caduca**; renovar cada sesion) |

4. **Variables** (Environment o Repository)

| Variable | Valor (tu lab) |
|----------|----------------|
| `AWS_REGION` | `us-east-1` |
| `TF_STATE_BUCKET` | `freshbox-ep1-tfstate-613895857683` |
| `TF_LOCK_TABLE` | `freshbox-ep1-terraform-locks` |

## Como desplegar (semi-auto)

1. Actualiza los 3 Secrets con el Session Token fresco del lab
2. Actions → **Deploy Lab (semi-auto)** → **Run workflow**
3. Parametros:
   - `action=plan` → solo plan (confirm vacio OK)
   - `action=apply` + `confirm=DEPLOY`
   - `action=full-deploy` + `confirm=DEPLOY` (infra + imagenes + recycle ASG)
   - `action=destroy` + `confirm=DESTROY`

## Requisitos en el repo (ya resueltos)

- `01-cloud-infrastructure/environments/clases/terraform.tfvars` **versionado** (`aws_profile = ""`)
- `backend.tf` con `backend "s3" {}` (Actions genera `backend.hcl` en el runner)
- Local: `export AWS_PROFILE=clases` (no hace falta perfil en el tfvars)

## Notas Learner Lab

- No usamos OIDC (no se pueden crear roles IAM en el lab)
- No hay apply automatico en `push` (protege presupuesto)
- Si `sts get-caller-identity` falla → renueva `AWS_SESSION_TOKEN`
- Si `terraform plan` en `00` falla con `GetBucketObjectLockConfiguration` → SCP del lab; el bucket ya existe, no hace falta re-aplicar `00`
