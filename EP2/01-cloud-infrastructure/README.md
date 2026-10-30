# FreshBox EP2 — Terraform (todo en un apply)

Un solo flujo: **init → plan → apply**.  
Terraform crea la red, EKS, RDS Multi-AZ, ECR, sube las imágenes, instala el ALB Controller, despliega los 5 microservicios + HPA + Ingress y ejecuta `init.sql`.

## Requisitos en tu máquina

- Credenciales **AWS Academy Learner Lab** activas (`aws sts get-caller-identity`)
- Terraform >= 1.5
- AWS CLI, Docker (build ARM64), kubectl, Helm

## Despliegue

```bash
cd EP2/01-cloud-infrastructure

terraform init
terraform plan
terraform apply
```

Al terminar:

```bash
terraform output -raw app_url
```

Abre esa URL (`http://…elb.amazonaws.com`) y prueba el CRUD.

## Qué hace el apply

| Paso | Recurso |
|------|---------|
| VPC 10.20.0.0/22 + NAT + SG | módulos network/routing/security-groups |
| ECR ×5 | módulo ecr |
| RDS MySQL Multi-AZ db.t4g.small | módulo rds |
| EKS + Node Group t4g.small 2–4 | módulo eks |
| `docker build/push` ARM64 | `null_resource.ecr_push` |
| ALB Controller | Helm |
| Namespace, Deployments, Services, HPA, Ingress | provider kubernetes |
| `init.sql` | Job `freshbox-bootstrap-rds` en el cluster |

Por defecto **solo infra** (`deploy_application = false`).

Cuando la infra esté OK y quieras el ZIP/app:

```hcl
deploy_application = true
```

luego `terraform apply` de nuevo.

## Destruir

```bash
terraform destroy
```

Si el ALB deja ENIs huérfanas, borra el Ingress antes o reintenta el destroy.

## Notas Academy

- IAM: `LabRole` (no se crean roles)
- Si falla el addon CloudWatch: `enable_cloudwatch_observability_addon = false`
- El apply completo puede tardar **25–40 min** (EKS + RDS Multi-AZ + imágenes)
