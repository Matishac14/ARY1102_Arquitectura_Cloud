# GitHub Actions — FreshBox EP1

## Workflows

| Workflow | Trigger | Proposito |
|----------|---------|-----------|
| `terraform-ci.yml` | PR / push | `fmt` + `validate` + cache providers |
| `deploy-lab.yml` | **solo manual** | plan / apply / full-deploy / images-only / destroy |

## Orden correcto

1. **Local (una vez):** bootstrap `00-terraform-state` → S3 + DynamoDB
2. **GitHub:** Environment `clases` (Variables + Secrets)
3. **Actions:** `plan` → `full-deploy` (o `images-only` si solo cambias contenedores)

## State S3 (importante)

El `key` del backend **no** debe incluir el workspace. Terraform antepone `env:/<workspace>/`.

| Incorrecto (duplica clases) | Correcto |
|-----------------------------|----------|
| `clases/01-cloud-infrastructure/terraform.tfstate` | `01-cloud-infrastructure/terraform.tfstate` |
| → `env:/clases/clases/01-…` | → `env:/clases/01-cloud-infrastructure/terraform.tfstate` |

El workflow migra automaticamente la ruta vieja si existe. Local:

```bash
./03-deployment-scripts/migrate-tfstate-key.sh
```

## Environment `clases`

**Secrets:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`  
**Variables:**

| Variable | Valor |
|----------|--------|
| `AWS_REGION` | `us-east-1` |
| `TF_STATE_BUCKET` | `freshbox-ep1-tfstate-613895857683` |
| `TF_LOCK_TABLE` | `freshbox-ep1-terraform-locks` |

## Como desplegar

1. Renueva Session Token en Secrets
2. Actions → **Deploy Lab (semi-auto)** → Run workflow
3. Acciones:
   - `plan` — solo plan
   - `apply` + `DEPLOY` — solo infra
   - `full-deploy` + `DEPLOY` — infra + imagenes + recycle ASG
   - `images-only` + `DEPLOY` — solo build/push + recycle (sin apply)
   - `destroy` + `DESTROY`

El job summary muestra la URL del ALB. Abrir con **http://** (no https).

## Notas Learner Lab

- Sin OIDC (no se crean roles IAM)
- Sin apply automatico en push
- Token caduca → renovar Secrets
- Bootstrap `00`: si `plan` falla por Object Lock / SCP → `terraform plan -refresh=false`
