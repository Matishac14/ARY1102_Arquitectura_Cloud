# Plan de solución — EP2 FreshBox (EKS + RDS)

## Entregables

| Componente | Peso | Ubicación en repo |
|------------|------|-------------------|
| Informe técnico (1.1–1.3) | 40% | `informe/` |
| Defensa oral + demo AWS | 60% | `presentacion/` + lab Academy |

## Arquitectura TO-BE (resumen)

```
Internet → ALB (Ingress) → EKS pods (APP privada) → RDS MySQL Multi-AZ (DATA)
                              ↑
                             ECR (ARM64, t4g)
```

- Node Group: `t4g.small`, min 2 / max 4  
- SG: Internet → ALB :80/:443 → EKS → RDS :3306  
- HPA por backend; Container Insights  

## Fases

0. Organización repo (`EP1/` / `EP2/`) — **hecho**  
1. Fix routing CRUD (Ingress→frontend + nginx por método) — **hecho**  
2. Terraform VPC/SG/ECR/RDS/EKS (`01-cloud-infrastructure/`) — **hecho**  
3. Apply lab + bootstrap RDS + ALB Controller — pendiente credenciales  
4. Validación CRUD + capturas  
5. Informe + PPT  

## Riesgo conocido del material oficial

El Ingress enruta `/api/products` solo a `get-products`, pero el frontend llama POST/PUT/DELETE al mismo path en el ALB. Hay que corregir antes de la demo (ver README / implementación).
