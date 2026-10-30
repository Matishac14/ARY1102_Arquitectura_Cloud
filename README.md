# ARY1102 — Arquitectura Cloud (FreshBox SpA)

Repositorio organizado por evaluación para trazabilidad. Cada carpeta `EP*` es **autocontenida**.

| Carpeta | Evaluación | Enfoque |
|---------|------------|---------|
| [`EP1/`](EP1/) | Evaluación Parcial 1 | EC2 + Docker + ALB + MySQL-on-EC2 (Terraform) |
| [`EP2/`](EP2/) | Evaluación Parcial 2 | Amazon EKS (5 pods) + RDS MySQL Multi-AZ + ALB Ingress |

## Cómo navegar

- **EP1:** infra Terraform, imágenes Docker, scripts de lab, informe y diagrama AS-IS.
- **EP2:** enunciado, Terraform EKS+RDS, app/manifiestos K8s, arquitectura TO-BE, presentación HTML.
- **GitHub Actions** (`.github/`): workflow de lab EP1; rutas apuntan a `EP1/`.

## Convención

- No mezclar entregables entre carpetas.
- Si se reutiliza algo de EP1 en EP2, se **copia** dentro de `EP2/` (p. ej. `EP2/arquitectura/as-is-ep1/`).
- Prefijos AWS sugeridos: `freshbox-ep1-*` / `freshbox-ep2-*` para no cruzar recursos en Academy.
- No versionar: `.terraform/`, `*.tfstate`, `terraform.tfvars`, `backend.hcl`, `**/k8s/secret.yaml`, informes/PDF locales (`documentos/`).
- Secretos K8s: copiar `secret.yaml.example` → `secret.yaml` antes de aplicar.
