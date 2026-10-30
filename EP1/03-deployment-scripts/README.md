# Scripts de despliegue FreshBox EP1

Helpers para operar el lab **en local**. El camino preferido de despliegue es GitHub Actions ([`.github/README.md`](../.github/README.md)).

| Script | Uso |
|--------|-----|
| `setup-lab-credentials.sh` | Carga Access Key + Secret + Session Token (`source`) |
| `_require-aws-credentials.sh` | Chequeo interno: falla si no hay credenciales |
| `build-container-images.sh` | Build local ARM64 de los 5 contenedores |
| `push-images-to-ecr.sh` | Build + push a ECR |
| `deploy-docker-services.sh` | Recicla instancias del ASG (user-data vuelve a hacer pull) |
| `migrate-tfstate-key.sh` | Corrige ruta S3 duplicada `env:/clases/clases/...` |
| `validate-ep1.sh` | Valida infra + CRUD vía ALB |
| `recreate-from-zero.sh` | Destroy+apply local (preferir Actions `full-deploy`) |
| `use-workspace-clases.sh` | Selecciona workspace Terraform `clases` |

## Credenciales del lab

```bash
source ./03-deployment-scripts/setup-lab-credentials.sh
aws sts get-caller-identity
```

Origen: lab → **AWS Details** (Access key, Secret key, Session token).  
En **CloudShell** del lab las credenciales ya vienen cargadas.

## Flujo local típico (si no usas Actions)

```bash
export AWS_PROFILE=clases
cd 01-cloud-infrastructure
terraform workspace select clases
terraform apply -var-file=environments/clases/terraform.tfvars
cd ..
./03-deployment-scripts/push-images-to-ecr.sh
./03-deployment-scripts/deploy-docker-services.sh
./03-deployment-scripts/validate-ep1.sh
```
