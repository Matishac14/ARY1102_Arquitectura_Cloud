# FreshBox SpA — Plataforma de Catalogo Online (EP1 / ARY1102)

Basado en el ZIP oficial `desarrolloappEP1` + Terraform + GitHub Actions (semi-auto) para AWS Academy Learner Lab.

## Arquitectura

```
Internet → ALB (public) → ASG EC2+Docker (private app, Multi-AZ)
                              ↓
                         EC2 MariaDB (private data) + AWS Backup
```

State remoto: S3 + DynamoDB (`00-terraform-state`) · Workspace: `clases`

## GitHub Actions (semi-automatico)

Detalle: [`.github/README.md`](.github/README.md)

1. Bootstrap state (una vez, local):

```bash
export AWS_PROFILE=clases
cd 00-terraform-state
cp terraform.tfvars.example terraform.tfvars   # pon tu Account ID en el bucket
terraform init && terraform apply
```

2. En GitHub → Settings → Environments → **`clases`**:
   - **Secrets:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
   - **Variables:** `AWS_REGION`, `TF_STATE_BUCKET`, `TF_LOCK_TABLE`

3. Actions → **Deploy Lab (semi-auto)** → Run workflow:
   - `plan` (sin confirm especial)
   - `apply` + confirm `DEPLOY`
   - `full-deploy` + confirm `DEPLOY` (infra + ECR + recycle ASG)
   - `destroy` + confirm `DESTROY`

Renueva el **Session Token** en Secrets cada vez que abras el lab.

CI en PRs: **Terraform CI** (`fmt` + `validate`, sin AWS).

## Arranque local (alternativa)

```bash
export AWS_PROFILE=clases
./03-deployment-scripts/recreate-from-zero.sh
```

O manual:

```bash
cd 01-cloud-infrastructure
cp backend.hcl.example backend.hcl   # edita bucket/table
terraform init -reconfigure -backend-config=backend.hcl
terraform workspace select clases || terraform workspace new clases
terraform apply -var-file=environments/clases/terraform.tfvars
cd ..
./03-deployment-scripts/push-images-to-ecr.sh
./03-deployment-scripts/deploy-docker-services.sh
```

## Prueba local (ZIP)

```bash
docker compose up -d --build
# http://localhost:8080
```

## Cerrar lab

```bash
# Local o workflow destroy + confirm DESTROY
cd 01-cloud-infrastructure
terraform destroy -var-file=environments/clases/terraform.tfvars
```
