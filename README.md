# FreshBox SpA — Plataforma de Catálogo Online (EP1 / ARY1102)

Terraform + Docker + GitHub Actions (semi-auto) para **AWS Academy Learner Lab**, basado en el ZIP `desarrolloappEP1`.

## Diagrama de arquitectura

Vista completa (también en [`04-architecture-evidence/arquitectura-freshbox.md`](04-architecture-evidence/arquitectura-freshbox.md)):

```mermaid
flowchart TB
  subgraph Internet["Internet"]
    User["Usuario / Demo"]
  end

  subgraph Public["Capa pública · 2 AZ"]
    ALB["ALB :80<br/>freshbox-ep1-alb"]
    NAT["NAT Gateway"]
    IGW["Internet Gateway"]
  end

  subgraph App["Capa privada App · ASG t4g.small"]
    EC2A["EC2 App AZ-a<br/>Docker"]
    EC2B["EC2 App AZ-b<br/>Docker"]
    subgraph Docker["Contenedores por instancia"]
      FE["nginx frontend :80"]
      GP["get-products :3001"]
      CP["create-product :3002"]
      UP["update-product :3003"]
      DP["delete-product :3004"]
    end
  end

  subgraph Data["Capa privada Data"]
    DB["EC2 MariaDB :3306"]
    BK["AWS Backup<br/>retención 7 días"]
  end

  subgraph Shared["Servicios compartidos"]
    ECR["ECR ×5 (ARM64)"]
    S3["S3 tfstate"]
    DDB["DynamoDB locks"]
  end

  User -->|HTTP| ALB
  ALB --> EC2A
  ALB --> EC2B
  EC2A --- Docker
  EC2B --- Docker
  FE --> GP & CP & UP & DP
  GP & CP & UP & DP -->|3306| DB
  DB --- BK
  EC2A & EC2B -->|pull| ECR
  EC2A & EC2B --> NAT --> IGW
  S3 --- DDB
```

## Estructura del repo

| Carpeta | Rol |
|---------|-----|
| `00-terraform-state/` | Bootstrap S3 + DynamoDB (state remoto) |
| `01-cloud-infrastructure/` | VPC, ALB, ASG, MySQL, ECR, Backup |
| `02-container-images/` | Notas de imágenes |
| `03-deployment-scripts/` | Scripts locales (push, deploy, validate) |
| `04-architecture-evidence/` | Diagramas + checklist de evidencia EP1 |
| `.github/workflows/` | CI + Deploy Lab semi-auto |

## Despliegue recomendado (GitHub)

Detalle: [`.github/README.md`](.github/README.md)

1. **Una vez (local):** bootstrap `00-terraform-state`
2. **GitHub Environment `clases`:** Secrets AWS + Variables del bucket/tabla
3. **Actions → Deploy Lab (semi-auto):**
   - Primero `plan`
   - Luego `full-deploy` + confirmación `DEPLOY`
   - Cambios solo de app: `images-only` + `DEPLOY`

Abre el ALB siempre con **`http://`** (no hay listener HTTPS).

## Arranque local (alternativa)

```bash
export AWS_PROFILE=clases
cd 01-cloud-infrastructure
cp backend.hcl.example backend.hcl   # edita bucket/table
terraform init -reconfigure -backend-config=backend.hcl
terraform workspace select clases || terraform workspace new clases
terraform apply -var-file=environments/clases/terraform.tfvars
cd ..
./03-deployment-scripts/push-images-to-ecr.sh
./03-deployment-scripts/deploy-docker-services.sh
./03-deployment-scripts/validate-ep1.sh
```

## Prueba del ZIP (sin AWS)

```bash
docker compose up -d --build
# http://localhost:8080
```

## Cerrar el lab

Workflow `destroy` + confirmación `DESTROY`, o:

```bash
cd 01-cloud-infrastructure
terraform destroy -var-file=environments/clases/terraform.tfvars
```
