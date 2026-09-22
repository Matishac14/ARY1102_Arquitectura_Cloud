# Scripts de despliegue FreshBox EP1

| Script | Uso |
|--------|-----|
| `setup-lab-credentials.sh` | Carga Access Key + Secret + Session Token del lab (`source`) |
| `_require-aws-credentials.sh` | Chequeo interno: falla si no hay credenciales |
| `build-container-images.sh` | Build local ARM64 de los 5 contenedores |
| `push-images-to-ecr.sh` | Build + push a ECR |
| `deploy-docker-services.sh` | Redeploy en ASG (recycle instancias) |
| `migrate-tfstate-key.sh` | Corrige ruta S3 duplicada `env:/clases/clases/...` |
| `validate-ep1.sh` | Valida infra + CRUD via ALB |
| `recreate-from-zero.sh` | Destroy+apply local (preferir GitHub Actions) |
| `use-workspace-clases.sh` | Selecciona workspace Terraform `clases` |

## Prerrequisito: credenciales del lab

En PC local **no** hay credenciales hasta que las cargues:

```bash
source ./03-deployment-scripts/setup-lab-credentials.sh
```

Origen: lab → **AWS Details** (Access key, Secret key, Session token).  
CloudShell del lab ya las trae. Docker + `terraform apply` previo siguen siendo necesarios para push/deploy.
