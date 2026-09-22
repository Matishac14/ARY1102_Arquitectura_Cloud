# Documentos EP1 — FreshBox / ARY1102

| Archivo | Descripción |
|---------|-------------|
| `EP1-ARY1102-Informe-Tecnico-FreshBox.docx` | Informe técnico Componente 1 (plantilla DUOC 2026) |
| `EP1-ARY1102-Informe-Tecnico-FreshBox.pdf` | Exportación PDF del mismo informe |
| `_gen_ep1_informe.py` | Generador reproducible del Word (skill `duoc-presentations`) |

## Contenido alineado a la rúbrica EP1

- Portada, control de versiones, índice  
- Introducción  
- **1.1–1.7** (rol arquitecto, WAF, análisis, requerimientos, modelos de nube, justificación, validación)  
- Conclusiones, **Glosario**, Bibliografía APA 7  

Presentación oral (Componente 2, 60%) — pendiente / fuera de este entregable.

## Regenerar

```bash
python3 documentos/_gen_ep1_informe.py
python3 ~/.cursor/skills/duoc-presentations/scripts/export_word_to_pdf.py \
  documentos/EP1-ARY1102-Informe-Tecnico-FreshBox.docx \
  documentos/EP1-ARY1102-Informe-Tecnico-FreshBox.pdf
```

Si el PDF falla en el entorno del agent (Word/LibreOffice), exporta localmente con Word: Archivo → Guardar como → PDF.

Revisa nombre/sección en el script (`ALUMNO`, `SECCION`) antes de entregar en Blackboard (AVA).
