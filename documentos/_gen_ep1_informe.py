# -*- coding: utf-8 -*-
from __future__ import annotations

import shutil
from datetime import date
from pathlib import Path

from docx import Document
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = Path.home() / ".cursor/skills/duoc-presentations/templates/word/duoc-informe-general.docx"
OUT = Path(__file__).resolve().parent / "EP1-ARY1102-Informe-Tecnico-FreshBox.docx"

NEGRO = RGBColor(0x1A, 0x1A, 0x1A)
TEXTO = RGBColor(0x2B, 0x2B, 0x2B)
GRIS = RGBColor(0x71, 0x71, 0x7A)
AMARILLO = "FFB800"
HEADER_BG = "1A1A1A"
ALT_ROW = "F0F4F8"

HOY = date.today().strftime("%d/%m/%Y")
ALUMNO = "Matías Fernández Z."
SECCION = "ARY1102 — Arquitectura Cloud"
EMAIL = "ma.fernandezz@duocuc.cl"


def set_run_font(run, size=11, bold=False, color=TEXTO, name="Aptos"):
    run.bold = bold
    run.font.size = Pt(size)
    run.font.color.rgb = color
    run.font.name = name
    rPr = run._element.get_or_add_rPr()
    rFonts = rPr.get_or_add_rFonts()
    rFonts.set(qn("w:ascii"), name)
    rFonts.set(qn("w:hAnsi"), name)


def shade_cell(cell, hex_color: str):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), hex_color)
    shd.set(qn("w:val"), "clear")
    tcPr.append(shd)


def set_cell_margins(cell, top=120, bottom=120, left=160, right=160):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement("w:tcMar")
    for m, v in (("top", top), ("bottom", bottom), ("left", left), ("right", right)):
        node = OxmlElement(f"w:{m}")
        node.set(qn("w:w"), str(v))
        node.set(qn("w:type"), "dxa")
        tcMar.append(node)
    tcPr.append(tcMar)


def cant_split_row(row):
    trPr = row._tr.get_or_add_trPr()
    trPr.append(OxmlElement("w:cantSplit"))


def style_header_row(row):
    cant_split_row(row)
    for cell in row.cells:
        shade_cell(cell, HEADER_BG)
        set_cell_margins(cell)
        for p in cell.paragraphs:
            p.paragraph_format.space_after = Pt(0)
            for run in p.runs:
                set_run_font(run, size=10, bold=True, color=RGBColor(0xFF, 0xFF, 0xFF))
        tcPr = cell._tc.get_or_add_tcPr()
        borders = OxmlElement("w:tcBorders")
        bottom = OxmlElement("w:bottom")
        bottom.set(qn("w:val"), "single")
        bottom.set(qn("w:sz"), "18")
        bottom.set(qn("w:color"), AMARILLO)
        borders.append(bottom)
        tcPr.append(borders)


def style_body_row(row, alt=False):
    cant_split_row(row)
    for cell in row.cells:
        if alt:
            shade_cell(cell, ALT_ROW)
        set_cell_margins(cell)
        for p in cell.paragraphs:
            p.paragraph_format.space_after = Pt(0)
            for run in p.runs:
                set_run_font(run, size=10, color=TEXTO)


def add_corp_table(doc, headers, rows):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr = table.rows[0]
    for i, h in enumerate(headers):
        hdr.cells[i].text = h
    style_header_row(hdr)
    for ri, row_data in enumerate(rows):
        row = table.rows[ri + 1]
        for ci, val in enumerate(row_data):
            row.cells[ci].text = str(val)
        style_body_row(row, alt=(ri % 2 == 1))
    doc.add_paragraph("")


def add_h1(doc, text):
    p = doc.add_paragraph(text, style="Heading 1")
    for run in p.runs:
        set_run_font(run, size=16, bold=True, color=NEGRO)
    p.paragraph_format.space_before = Pt(18)
    p.paragraph_format.space_after = Pt(8)
    pPr = p._p.get_or_add_pPr()
    pBdr = OxmlElement("w:pBdr")
    bottom = OxmlElement("w:bottom")
    bottom.set(qn("w:val"), "single")
    bottom.set(qn("w:sz"), "12")
    bottom.set(qn("w:space"), "4")
    bottom.set(qn("w:color"), AMARILLO)
    pBdr.append(bottom)
    pPr.append(pBdr)


def add_h2(doc, text):
    p = doc.add_paragraph(text, style="Heading 2")
    for run in p.runs:
        set_run_font(run, size=13, bold=True, color=NEGRO)
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(6)


def add_p(doc, text, bullet=False):
    p = doc.add_paragraph()
    run = p.add_run(("• " if bullet else "") + text)
    set_run_font(run, size=11, color=TEXTO)
    p.paragraph_format.space_after = Pt(6)
    p.paragraph_format.line_spacing_rule = WD_LINE_SPACING.SINGLE
    if bullet:
        p.paragraph_format.left_indent = Cm(0.5)


def add_callout(doc, title, body):
    table = doc.add_table(rows=1, cols=1)
    cell = table.rows[0].cells[0]
    cant_split_row(table.rows[0])
    shade_cell(cell, "F4F5F6")
    set_cell_margins(cell, 140, 140, 180, 180)
    tcPr = cell._tc.get_or_add_tcPr()
    borders = OxmlElement("w:tcBorders")
    left = OxmlElement("w:left")
    left.set(qn("w:val"), "single")
    left.set(qn("w:sz"), "24")
    left.set(qn("w:color"), AMARILLO)
    borders.append(left)
    for side in ("top", "bottom", "right"):
        b = OxmlElement(f"w:{side}")
        b.set(qn("w:val"), "nil")
        borders.append(b)
    tcPr.append(borders)
    cell.paragraphs[0].clear()
    r1 = cell.paragraphs[0].add_run(title)
    set_run_font(r1, size=10, bold=True, color=NEGRO)
    p2 = cell.add_paragraph()
    r2 = p2.add_run(body)
    set_run_font(r2, size=10, color=TEXTO)
    doc.add_paragraph("")


def clear_body_after_cover(doc):
    cut = None
    for p in doc.paragraphs:
        if p.style.name == "Heading 1":
            cut = p._element
            break
    if cut is None:
        return
    el = cut
    while el is not None:
        nxt = el.getnext()
        if el.tag == qn("w:sectPr"):
            break
        parent = el.getparent()
        if parent is None:
            break
        parent.remove(el)
        el = nxt
        if el is not None and el.tag == qn("w:sectPr"):
            break


def main():
    shutil.copy(TEMPLATE, OUT)
    doc = Document(str(OUT))

    mapping_idx = {
        2: ("INFORME TÉCNICO", 11, True, GRIS),
        3: ("Evaluación Parcial N°1 — ARY1102 Arquitectura Cloud", 22, True, NEGRO),
        4: (
            f"FreshBox SpA — Catálogo Online de Productos Orgánicos\nEstudiante: {ALUMNO} · {SECCION} · {HOY}",
            11,
            False,
            GRIS,
        ),
        6: ("Duoc UC · Instituto Profesional · 2026 · #VerdaderamenteConectad@s", 10, False, GRIS),
    }
    for idx, (text, size, bold, color) in mapping_idx.items():
        p = doc.paragraphs[idx]
        p.clear()
        run = p.add_run(text)
        set_run_font(run, size=size, bold=bold, color=color)

    if doc.tables:
        meta = [
            ("Código Documental:", "INF-ARY1102-EP1-2026"),
            ("Versión:", "1.0"),
            ("Asignatura:", "ARY1102 Arquitectura Cloud"),
            ("Estudiante:", f"{ALUMNO} ({EMAIL})"),
            ("Fecha:", HOY),
            ("Entorno:", "AWS Academy Learner Lab · us-east-1 · workspace clases"),
        ]
        t0 = doc.tables[0]
        for ri, (k, v) in enumerate(meta):
            if ri < len(t0.rows):
                t0.rows[ri].cells[0].text = k
                t0.rows[ri].cells[1].text = v

    # Remove leftover sample tables after meta (versions, synthesis, etc.)
    # Keep only first table (ficha)
    while len(doc.tables) > 1:
        tbl = doc.tables[1]._tbl
        tbl.getparent().remove(tbl)

    clear_body_after_cover(doc)

    add_h1(doc, "Control de Versiones y Aprobaciones")
    add_corp_table(
        doc,
        ["Versión", "Fecha", "Elaborado por", "Revisado por", "Estado"],
        [
            ["0.9", HOY, ALUMNO, "—", "○ Borrador"],
            ["1.0", HOY, ALUMNO, "Docente ARY1102", "● Entrega EP1"],
        ],
    )

    add_h1(doc, "Índice de Contenidos")
    for line in [
        "Introducción",
        "1.1 Fundamentación del rol del arquitecto cloud (IE1.1.2)",
        "1.2 Pilares del Well-Architected Framework (IE1.2.1)",
        "1.3 Análisis de arquitectura según Well-Architected (IE1.2.2)",
        "1.4 Priorización de requerimientos (IE1.3.2)",
        "1.5 Comparación de modelos de nube (IE2.1.1)",
        "1.6 Justificación del modelo cloud (IE2.1.2)",
        "1.7 Validación del diseño (IE2.2.2)",
        "Conclusiones",
        "Glosario",
        "Referencias (APA 7)",
    ]:
        add_p(doc, line)

    add_h1(doc, "Introducción")
    add_p(
        doc,
        "FreshBox SpA es una empresa de venta online de productos orgánicos y saludables con despacho "
        "en la Región Metropolitana. El crecimiento sostenido del 40% trimestral exige modernizar la "
        "plataforma tecnológica hacia un modelo cloud que permita administrar un catálogo online "
        "(CRUD de productos) con alta disponibilidad, escalabilidad y costos predecibles.",
    )
    add_p(
        doc,
        "Este informe técnico corresponde al Componente 1 de la Evaluación Parcial N°1 (EP1) de la "
        "asignatura ARY1102. Se fundamenta el rol del arquitecto cloud, se aplican los seis pilares "
        "del AWS Well-Architected Framework, se priorizan requerimientos, se justifica el modelo de "
        "nube pública y se valida el diseño TO-BE de tres capas implementado en AWS Academy Learner Lab "
        "mediante Infrastructure as Code (Terraform), contenedores Docker (ARM64) y despliegue "
        "semi-automático con GitHub Actions.",
    )
    add_callout(
        doc,
        "Alcance EP1",
        "Catálogo administrable (GET/POST/PUT/DELETE). Carrito y órdenes quedan fuera de alcance "
        "para etapas posteriores. Implementación en us-east-1 respetando límites del Learner Lab "
        "(LabRole/LabInstanceProfile, t4g.small, sin creación de roles IAM propios).",
    )

    add_h1(doc, "1.1 Fundamentación del rol del arquitecto cloud (IE1.1.2)")
    add_p(
        doc,
        "El arquitecto cloud traduce objetivos de negocio en decisiones tecnológicas medibles. En "
        "FreshBox, el objetivo central es sostener el crecimiento del 40% trimestral sin degradar "
        "disponibilidad ni disparar costos fijos de infraestructura on-premises.",
    )
    add_h2(doc, "Responsabilidades técnicas")
    for t in [
        "Diseñar la topología de red Multi-AZ (VPC /22, subredes públicas y privadas, IGW, NAT).",
        "Definir segmentación de seguridad por capa (Security Groups ALB → App → Data).",
        "Seleccionar cómputo adecuado al lab (EC2 t4g.small ARM + Docker + ASG min 2 / max 4).",
        "Garantizar persistencia y recuperación (MariaDB en capa Data + AWS Backup 7 días).",
        "Automatizar el despliegue (Terraform, ECR, GitHub Actions workflow_dispatch).",
    ]:
        add_p(doc, t, bullet=True)
    add_h2(doc, "Responsabilidades estratégicas")
    for t in [
        "Alinear CAPEX→OPEX: pagar por uso del lab/cloud en lugar de comprar servidores físicos.",
        "Priorizar time-to-market del catálogo (MVP) sin comprometer HA ni seguridad básica.",
        "Documentar trade-offs del Learner Lab (sin OIDC/IAM custom, Session Token temporal).",
        "Definir criterios de aceptación verificables (targets healthy, CRUD vía ALB en HTTP).",
    ]:
        add_p(doc, t, bullet=True)
    add_p(
        doc,
        "Así, cada decisión (por ejemplo un solo NAT por presupuesto del lab, o ASG en lugar de "
        "instancias fijas) queda vinculada al negocio: crecer sin interrupciones y operar con costo "
        "controlado.",
    )

    add_h1(doc, "1.2 Pilares del Well-Architected Framework (IE1.2.1)")
    add_p(
        doc,
        "El AWS Well-Architected Framework (WAF) organiza el diseño en seis pilares. A continuación "
        "se describen y se vinculan al caso FreshBox SpA.",
    )
    add_corp_table(
        doc,
        ["Pilar", "Qué implica", "Aplicación en FreshBox EP1"],
        [
            ["Excelencia operativa", "Operar, monitorear y mejorar", "IaC con Terraform; deploy semi-auto (Actions); scripts validate-ep1"],
            ["Seguridad", "Protección de datos y privilegio mínimo", "SG por capa; EBS cifrado; BD solo desde App; LabRole existente"],
            ["Confiabilidad", "Recuperación y HA", "Multi-AZ, ALB, ASG min 2, AWS Backup 7 días"],
            ["Eficiencia de rendimiento", "Recursos acordes a la demanda", "t4g.small ARM; contenedores; ASG hasta 4"],
            ["Optimización de costos", "Evitar desperdicio", "1 NAT; sin HTTPS/ACM (lab); destroy al cerrar; on-demand locks"],
            ["Sostenibilidad", "Menor impacto energético", "Graviton (ARM); apagado/destroy del lab; menos overprovisioning"],
        ],
    )

    add_h1(doc, "1.3 Análisis de arquitectura según Well-Architected (IE1.2.2)")
    add_h2(doc, "Riesgos identificados")
    add_corp_table(
        doc,
        ["Pilar", "Riesgo", "Severidad"],
        [
            ["Seguridad", "ALB solo HTTP (sin TLS) — tráfico en claro hacia Internet", "Media (aceptable en lab)"],
            ["Confiabilidad", "Un solo NAT: SPOF de salida a Internet/ECR desde App", "Media"],
            ["Confiabilidad", "MySQL/MariaDB en una sola AZ (EC2 dedicado)", "Media-Alta"],
            ["Excelencia operativa", "Session Token del lab caduca → Actions falla si no se renueva", "Alta operativa"],
            ["Costos", "Olvidar destroy mantiene NAT/ALB/EC2 consumiendo créditos", "Alta"],
            ["Seguridad", "SCP deniega GetBucketObjectLockConfiguration en S3 state", "Baja (operativa)"],
        ],
    )
    add_h2(doc, "Oportunidades de mejora y recomendaciones")
    for t in [
        "Producción: añadir listener HTTPS (ACM) y redirigir HTTP→HTTPS.",
        "Data: migrar a Amazon RDS Multi-AZ cuando el lab/curso lo permita.",
        "Red: segundo NAT o endpoints VPC para ECR y reducir dependencia del NAT único.",
        "Operación: alarmas CloudWatch en targets unhealthy y CPU del ASG.",
        "CI/CD: fuera del lab, preferir OIDC a Secrets temporales.",
    ]:
        add_p(doc, t, bullet=True)

    add_h1(doc, "1.4 Priorización de requerimientos (IE1.3.2)")
    add_p(
        doc,
        "Se clasifican requerimientos funcionales (RF) y no funcionales (RNF) según impacto en el "
        "MVP del catálogo y en el crecimiento del 40% trimestral.",
    )
    add_corp_table(
        doc,
        ["ID", "Requerimiento", "Tipo", "Prioridad", "Criterio"],
        [
            ["RF-01", "Listar productos (GET)", "Funcional", "Alta", "Core del catálogo"],
            ["RF-02", "Crear / actualizar / eliminar productos", "Funcional", "Alta", "Administración MVP"],
            ["RF-03", "Frontend web vía ALB", "Funcional", "Alta", "Canal de demo y negocio"],
            ["RNF-01", "Alta disponibilidad Multi-AZ", "No funcional", "Alta", "Crecimiento sin downtime"],
            ["RNF-02", "Escalabilidad horizontal (ASG)", "No funcional", "Alta", "Picos de tráfico"],
            ["RNF-03", "Segmentación de red y cifrado EBS", "No funcional", "Alta", "Seguridad / cumplimiento"],
            ["RNF-04", "Backup de base de datos (7 días)", "No funcional", "Media", "DR básico EP1"],
            ["RF-04", "Carrito y órdenes", "Funcional", "Baja", "Fuera de alcance EP1"],
            ["RNF-05", "HTTPS público / WAF / Shield", "No funcional", "Media", "Diferido (lab/costo)"],
        ],
    )
    add_p(
        doc,
        "La solución cloud prioriza Alta: CRUD + HA + seguridad por capas + ASG/contenedores. "
        "Lo diferido (carrito, TLS productivo) no bloquea el valor del EP1 ni la demo.",
    )

    add_h1(doc, "1.5 Comparación de modelos de nube (IE2.1.1)")
    add_corp_table(
        doc,
        ["Criterio", "Pública", "Privada", "Híbrida"],
        [
            ["Costos", "OPEX, pago por uso; ideal para startup/MVP", "CAPEX alto (datacenter/HW)", "Mixto; complejidad de integración"],
            ["Seguridad", "Responsabilidad compartida; SG/IAM maduros", "Control total físico/lógico", "Políticas duales; mayor superficie"],
            ["Escalabilidad", "Elástica (ASG, regiones)", "Limitada por capacidad comprada", "Escalado cloud + legado on-prem"],
            ["Ventaja FreshBox", "Time-to-market y lab Academy", "No justifica CAPEX en etapa 1", "Overengineering para catálogo MVP"],
            ["Desventaja FreshBox", "Dependencia del proveedor / límites lab", "Inversión y lead time", "Operación más cara de sostener"],
        ],
    )

    add_h1(doc, "1.6 Justificación del modelo cloud (IE2.1.2)")
    add_h2(doc, "Modelo seleccionado: nube pública (AWS)")
    add_p(
        doc,
        "Se selecciona nube pública AWS (Learner Lab) porque permite implementar en horas una "
        "arquitectura Multi-AZ con servicios de balanceo, registro de contenedores y backup, "
        "alineada al enunciado EP1 y a las restricciones académicas.",
    )
    add_h2(doc, "Justificación técnica")
    for t in [
        "Servicios nativos: VPC, ALB, ASG, ECR, EC2, AWS Backup.",
        "Contenedores ARM64 (Graviton) coherentes con t4g.small del lab.",
        "IaC reproducible (Terraform workspace clases + state remoto S3/DynamoDB).",
    ]:
        add_p(doc, t, bullet=True)
    add_h2(doc, "Justificación financiera (CAPEX → OPEX)")
    add_p(
        doc,
        "Evitar compra de servidores, switches y UPS (CAPEX). El lab opera bajo créditos/consumo "
        "(OPEX). Un solo NAT y destroy al cerrar sesión reducen desperdicio. La elasticidad del ASG "
        "evita dimensionar para el pico permanente.",
    )
    add_h2(doc, "Justificación estratégica")
    add_p(
        doc,
        "Soporta el crecimiento del 40% trimestral con HA (ALB + Multi-AZ + ASG) y deja una base "
        "extensible (RDS, HTTPS, más microservicios) sin rehacer la red de tres capas.",
    )

    add_h1(doc, "1.7 Validación del diseño (IE2.2.2)")
    add_p(
        doc,
        "La arquitectura implementada cumple el TO-BE de tres capas del enunciado. Validación "
        "teórica y evidencia de implementación en el Learner Lab:",
    )
    add_corp_table(
        doc,
        ["Criterio", "Diseño / implementación", "Estado"],
        [
            ["Alta disponibilidad", "Subredes en 2 AZ; ALB; ASG min 2; health check /", "● Cumple"],
            ["Escalabilidad", "ASG max 4; 5 contenedores Docker; imágenes en ECR ARM64", "● Cumple"],
            ["Buenas prácticas de red", "VPC 10.0.0.0/22; 6 subredes; IGW; NAT; tablas de ruteo", "● Cumple"],
            ["Seguridad por capas", "SG ALB:80←Internet; App:80←ALB; Data:3306←App; EBS cifrado", "● Cumple"],
            ["Datos y DR", "EC2 MariaDB privada + AWS Backup retención 7 días", "● Cumple"],
            ["Aplicación CRUD", "Frontend nginx + 4 APIs; CRUD vía http://ALB/api/products", "● Cumple (demo)"],
            ["Automatización", "Terraform + GitHub Actions (plan/apply/full-deploy/images-only)", "● Cumple"],
        ],
    )
    add_h2(doc, "Diagrama lógico de capas (resumen)")
    add_p(
        doc,
        "Internet → ALB (pública) → ASG EC2+Docker (privada App, Multi-AZ) → EC2 MariaDB "
        "(privada Data) + AWS Backup. El detalle Mermaid del repositorio está en "
        "04-architecture-evidence/arquitectura-freshbox.md (acompañar capturas de consola en la "
        "defensa oral / Componente 2).",
    )
    add_callout(
        doc,
        "Nota de diseño respecto al enunciado (puerto 443)",
        "El enunciado sugiere 80/443 en ALB/App. En esta implementación el ALB expone solo HTTP :80 "
        "(sin certificado ACM en el lab). La segmentación mínima ALB→App→Data y el cifrado EBS se "
        "mantienen. Usar siempre http:// en la URL del ALB.",
    )

    add_h1(doc, "Conclusiones")
    add_p(
        doc,
        "FreshBox SpA requiere una base cloud que acompañe su crecimiento sin elevar CAPEX ni "
        "comprometer disponibilidad. Se adoptó nube pública AWS con arquitectura de tres capas, "
        "contenedores y automatización, aplicando el Well-Architected Framework de forma explícita "
        "a riesgos y mejoras.",
    )
    add_p(
        doc,
        "La implementación en AWS Academy Learner Lab valida HA (ALB/ASG/Multi-AZ), seguridad por "
        "capas, backup y CRUD end-to-end. Quedan como evolución natural HTTPS, RDS Multi-AZ y "
        "observabilidad avanzada, coherentes con el roadmap del negocio más allá del EP1.",
    )

    add_h1(doc, "Glosario")
    add_p(
        doc,
        "Siglas y términos usados en este informe (expansión completa en la primera aparición en el cuerpo).",
    )
    add_corp_table(
        doc,
        ["Término", "Significado"],
        [
            ["ALB", "Application Load Balancer — balanceador de carga de aplicación HTTP"],
            ["ASG", "Auto Scaling Group — grupo de autoescalado de instancias EC2"],
            ["AZ", "Availability Zone — zona de disponibilidad dentro de una región AWS"],
            ["CAPEX", "Capital Expenditure — gasto de capital (inversión en activos)"],
            ["CRUD", "Create, Read, Update, Delete — operaciones básicas de datos"],
            ["EBS", "Elastic Block Store — volúmenes de bloque para EC2"],
            ["ECR", "Elastic Container Registry — registro de imágenes Docker"],
            ["IaC", "Infrastructure as Code — infraestructura definida como código (Terraform)"],
            ["IGW", "Internet Gateway — puerta de enlace a Internet de la VPC"],
            ["MVP", "Minimum Viable Product — producto mínimo viable"],
            ["NAT", "Network Address Translation — salida controlada desde subredes privadas"],
            ["OPEX", "Operational Expenditure — gasto operacional recurrente"],
            ["SCP", "Service Control Policy — política de control de servicios en Organizations"],
            ["SG", "Security Group — firewall stateful a nivel de instancia/ENI"],
            ["VPC", "Virtual Private Cloud — red virtual aislada en AWS"],
            ["WAF (AWS)", "Well-Architected Framework — marco de buenas prácticas AWS"],
            ["AVA", "Ambiente Virtual de Aprendizaje — entorno/aula digital Duoc (concepto)"],
            ["LMS", "Learning Management System — plataforma del aula (p. ej. Blackboard)"],
        ],
    )

    add_h1(doc, "Referencias")
    refs = [
        "Amazon Web Services. (n.d.). AWS Well-Architected Framework. https://aws.amazon.com/architecture/well-architected/",
        "Amazon Web Services. (n.d.). Auto Scaling groups. https://docs.aws.amazon.com/autoscaling/",
        "Amazon Web Services. (n.d.). Elastic Load Balancing — Application Load Balancers. https://docs.aws.amazon.com/elasticloadbalancing/",
        "HashiCorp. (n.d.). Terraform AWS Provider documentation. https://registry.terraform.io/providers/hashicorp/aws/latest/docs",
        "Pastenet, I. A. (2026). Evaluación Parcial N°1 — ARY1102 Arquitectura Cloud (encargo estudiante). Duoc UC.",
        "Pastenet, I. A. (2026). desarrolloappEP1 (recursos de microservicios y guía docente). Duoc UC.",
    ]
    for r in refs:
        p = doc.add_paragraph()
        run = p.add_run(r)
        set_run_font(run, size=10, color=TEXTO)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.left_indent = Cm(0.75)
        p.paragraph_format.first_line_indent = Cm(-0.75)

    for sec in doc.sections:
        sec.top_margin = Cm(2)
        sec.bottom_margin = Cm(2)
        sec.left_margin = Cm(2)
        sec.right_margin = Cm(2)

    doc.save(str(OUT))
    print("Wrote", OUT, "size", OUT.stat().st_size)


if __name__ == "__main__":
    main()
