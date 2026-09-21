# Scripts de despliegue FreshBox EP1

| Script | Uso |
|--------|-----|
| `setup-lab-credentials.sh` | Carga Access Key + Secret + Session Token del lab (`source`) |
| `_require-aws-credentials.sh` | Chequeo interno: falla si no hay credenciales |
| `build-container-images.sh` | Build local ARM64 de los 5 contenedores |
| `push-images-to-ecr.sh` | Build + push a ECR |
| `deploy-docker-services.sh` | Redeploy en instancias del ASG via SSM |

## Prerrequisito: credenciales del lab

En PC local **no** hay credenciales hasta que las cargues:

```bash
source ./03-deployment-scripts/setup-lab-credentials.sh
```

Origen: lab → **AWS Details** (Access key, Secret key, Session token).  
CloudShell del lab ya las trae. Docker + `terraform apply` previo siguen siendo necesarios para push/deploy.
