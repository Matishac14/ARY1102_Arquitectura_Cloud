# FreshBox SpA — EP2 (EKS + RDS Multi-AZ)

> Carpeta autocontenida de la **Evaluación Parcial 2**.  
> Índice del repo: [`../README.md`](../README.md) · EP1 (AS-IS): [`../EP1/`](../EP1/)

## Objetivo

Migrar el catálogo FreshBox desde EC2+Docker+MySQL-on-EC2 (EP1) hacia:

- **Amazon EKS** — 5 Deployments (frontend + 4 APIs), ~10 pods (2 réplicas)
- **Amazon RDS MySQL Multi-AZ** — `db.t4g.small`
- **ALB Ingress** + HPA + CloudWatch Container Insights

Prefijo sugerido de recursos: `freshbox-ep2-*` / cluster `freshbox-cluster` / namespace `freshbox`.

## Estructura

| Ruta | Contenido |
|------|-----------|
| [`enunciado/`](enunciado/) | PDF oficial EP2 |
| [`01-cloud-infrastructure/`](01-cloud-infrastructure/) | **Terraform**: VPC, EKS, RDS Multi-AZ, ECR, SG |
| [`scripts/`](scripts/) | Deploy: render K8s, ALB Controller, apply, bootstrap RDS |
| [`desarrolloapp/`](desarrolloapp/) | App + manifiestos K8s + scripts (zip oficial) |
| [`arquitectura/`](arquitectura/) | Diagramas TO-BE; `as-is-ep1/` copiado desde EP1 |
| [`informe/`](informe/) | Informe técnico EP2 (encargo 40%) |
| [`presentacion/`](presentacion/) | PPT + guion demo 10 min (60%) |
| [`documentos/`](documentos/) | Evidencias / capturas |
| [`referencia-act2.3/`](referencia-act2.3/) | Material ACT 2.3 previo (referencia, no sustituye el zip oficial) |
| [`PLAN-SOLUCION.md`](PLAN-SOLUCION.md) | Plan de implementación acordado |

## Arranque rápido

**Fase 1 — solo infra** (default: `deploy_application = false`):

```bash
cd EP2/01-cloud-infrastructure
terraform init
terraform plan
terraform apply
```

**Fase 2 — app del ZIP** (cuando la infra esté OK): pon `deploy_application = true` y vuelve a `terraform apply`.

Detalle: [`01-cloud-infrastructure/README.md`](01-cloud-infrastructure/README.md)

## Relación con EP1

La línea base AS-IS está **copiada** en `arquitectura/as-is-ep1/` (no depende de rutas vivas de `EP1/` para el entregable EP2).
