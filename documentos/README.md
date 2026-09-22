# Documentos EP1 — FreshBox / ARY1102

| Archivo | Descripción |
|---------|-------------|
| `EP1-ARY1102-Informe-Tecnico-FreshBox.docx` | Informe técnico Componente 1 (plantilla DUOC 2026) |
| `_gen_ep1_informe.py` | Generador reproducible del Word |

## Aclaración pauta vs TO-BE (defensa)

| Elemento | Qué presentar |
|----------|----------------|
| **Implementación EP1 obligatoria** | VPC /22, 6 subredes, ALB, EC2+Docker, ASG 2–4, MySQL en EC2, 5 contenedores, CRUD vía ALB, SG por capa |
| **TO-BE empresarial** | ECS/Fargate, RDS Multi-AZ, WAF, Secrets Manager, CloudWatch/CloudTrail, CI/CD, NAT por AZ, VPC endpoints |

**Frase guía:** *La implementación de laboratorio cumple la pauta académica. El TO-BE elimina restricciones de Learner Lab y reduce riesgo operacional mediante servicios administrados.*

## Contenido (rúbrica 1.1–1.7)

Portada · versiones · índice · introducción · **1.1–1.7** (validación lab + TO-BE separados) · conclusiones · glosario · APA 7.

## Regenerar

```bash
python3 documentos/_gen_ep1_informe.py
python3 ~/.cursor/skills/duoc-presentations/scripts/prepare_docx_pagination.py \
  documentos/EP1-ARY1102-Informe-Tecnico-FreshBox.docx
```
