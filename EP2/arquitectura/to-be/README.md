# FreshBox EP2 — Diagrama TO-BE

## Recomendado para entrega (mismo estilo EP1)

Iconos **oficiales AWS** (Asset Package 07/2025) embebidos como en EP1 `architecture-freshbox.svg`:

| Archivo | Uso |
|---------|-----|
| `architecture-freshbox-ep2.html` | Visor HTML (abrir en navegador) |
| `architecture-freshbox-ep2.svg` | SVG embebible en informe / PPT |
| `aws-architecture.html` | Alias del mismo HTML oficial |
| `generate_ep2_official_diagram.py` | Regenerar si cambia el inventario |

```bash
python3 generate_ep2_official_diagram.py
open architecture-freshbox-ep2.html
```

## Otras variantes (comparación de skills)

| Skill | Archivos | Estilo |
|-------|----------|--------|
| **aws-architecture-diagrams-studio** | `architecture-model.yaml`, `aws-architecture.drawio` | Draw.io 3 capas / AZ / SG |
| **aws-architecture-diagram** (plugin) | `../../docs/freshbox-ep2-tobe-reference.drawio` | Reference Architecture + legend |

## VALIDATION WARNINGS

1. NAT Gateway único → SPOF de egress  
2. ALB creado por Ingress Controller (no `aws_lb` en Terraform)  
3. Réplicas base=1 en lab; HPA hasta 4  
