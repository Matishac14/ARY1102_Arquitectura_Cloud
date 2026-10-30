#!/usr/bin/env python3
"""
FreshBox EP2 TO-BE — diagrama HTML/SVG con iconos oficiales AWS (pack 07/2025).
Mismo patrón que EP1: generate_freshbox_diagram.py (base64 data:image/svg+xml).
"""
from __future__ import annotations

import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ICONS = Path("/Users/mfernandezz/.cursor/skills/aws-diagrams/resources/aws-icons-official")
GENERIC = Path("/Users/mfernandezz/.cursor/skills/aws-diagrams/resources")

icon_files = {
    "cloud_logo": "Architecture-Group-Icons_07312025/AWS-Cloud-logo_32.svg",
    "user": None,  # generic_users.svg (visible en fondo claro)
    "igw": "Resource-Icons_07312025/Res_Networking-Content-Delivery/Res_Amazon-VPC_Internet-Gateway_48.svg",
    "alb": "Architecture-Service-Icons_07312025/Arch_Networking-Content-Delivery/64/Arch_Elastic-Load-Balancing_64.svg",
    "alb_res": "Resource-Icons_07312025/Res_Networking-Content-Delivery/Res_Elastic-Load-Balancing_Application-Load-Balancer_48.svg",
    "nat": "Resource-Icons_07312025/Res_Networking-Content-Delivery/Res_Amazon-VPC_NAT-Gateway_48.svg",
    "eks": "Architecture-Service-Icons_07312025/Arch_Containers/64/Arch_Amazon-Elastic-Kubernetes-Service_64.svg",
    "ecr": "Architecture-Service-Icons_07312025/Arch_Containers/64/Arch_Amazon-Elastic-Container-Registry_64.svg",
    "asg": "Architecture-Service-Icons_07312025/Arch_Compute/64/Arch_Amazon-EC2-Auto-Scaling_64.svg",
    "rds": "Architecture-Service-Icons_07312025/Arch_Database/64/Arch_Amazon-RDS_64.svg",
    "cw": "Architecture-Service-Icons_07312025/Arch_Management-Governance/64/Arch_Amazon-CloudWatch_64.svg",
    "hpa": "Architecture-Service-Icons_07312025/Arch_Management-Governance/64/Arch_AWS-Application-Auto-Scaling_64.svg",
}


def data_uri(path: Path) -> str:
    return "data:image/svg+xml;base64," + base64.b64encode(path.read_bytes()).decode("ascii")


u: dict[str, str] = {}
for key, rel in icon_files.items():
    if key == "user":
        u[key] = data_uri(GENERIC / "generic_users.svg")
    else:
        p = ICONS / rel
        if not p.exists():
            raise SystemExit(f"Icono faltante: {p}")
        u[key] = data_uri(p)

# Layout rules (siempre):
# - Gaps Public↔App y App↔Data ≥ 64px para flechas + chips sin solape
# - Etiquetas en carril lateral / corredor inter-AZ, nunca sobre el stroke
# - Stubs verticales/horizontales ≥ 16px antes del marker
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1240" width="100%" height="100%" style="background:#F4F5F7; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <defs>
    <style>
      .card-box {{ fill: #FFFFFF; stroke: #D5DBDB; stroke-width: 1.2px; filter: drop-shadow(0 1px 3px rgba(0,0,0,0.04)); }}
      .flow-line {{ fill: none !important; stroke-linecap: square; stroke-linejoin: miter; }}
      .side-pill {{ filter: drop-shadow(0 1px 2px rgba(0,0,0,0.03)); }}
      .title-hero {{ font-size: 20px; font-weight: 800; fill: #16191F; letter-spacing: -0.2px; }}
      .sub-hero {{ font-size: 12px; font-weight: 500; fill: #545B64; }}
      .sec-title {{ font-size: 13px; font-weight: 700; fill: #16191F; }}
      .sec-meta {{ font-size: 11px; font-weight: 500; fill: #545B64; }}
      .az-title {{ font-size: 12.5px; font-weight: 800; fill: #232F3E; letter-spacing: 0.3px; }}
      .tag-text {{ font-size: 9.5px; font-weight: 700; text-transform: uppercase; fill: #FFFFFF; }}
      .pill-text {{ font-size: 9.5px; font-weight: 700; }}
    </style>
    <marker id="arr-purple" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M 1 1.5 L 9 5 L 1 8.5 z" fill="#8C4FFF"/>
    </marker>
    <marker id="arr-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M 1 1.5 L 9 5 L 1 8.5 z" fill="#0073BB"/>
    </marker>
    <marker id="arr-orange" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M 1 1.5 L 9 5 L 1 8.5 z" fill="#EC7211"/>
    </marker>
    <marker id="arr-sync" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M 1 1.5 L 9 5 L 1 8.5 z" fill="#3B48CC"/>
    </marker>
    <pattern id="grid-dots" width="20" height="20" patternUnits="userSpaceOnUse">
      <circle cx="2" cy="2" r="1.0" fill="#E2E5E8"/>
    </pattern>
  </defs>

  <rect width="1920" height="1240" fill="#F4F5F7"/>
  <rect width="1920" height="1240" fill="url(#grid-dots)"/>

  <!-- HEADER -->
  <g transform="translate(40, 20)">
    <rect width="1840" height="68" rx="4" class="card-box"/>
    <image href="{u['cloud_logo']}" x="20" y="12" width="44" height="44"/>
    <text x="76" y="32" class="title-hero">Arquitectura TO-BE EP2 · FreshBox SpA (EKS + RDS Multi-AZ · ARY1102)</text>
    <text x="76" y="52" class="sub-hero">VPC 10.20.0.0/22 · ALB Ingress → EKS Node Group t4g.small → RDS MySQL Multi-AZ · HPA · CloudWatch Container Insights</text>
    <g transform="translate(1630, 14)">
      <rect width="190" height="40" rx="3" fill="#F8FAFC" stroke="#D5DBDB"/>
      <text x="95" y="19" font-size="11" font-weight="700" fill="#16191F" text-anchor="middle">Duoc UC · ARY1102</text>
      <text x="95" y="33" font-size="10" font-weight="700" fill="#1E8900" text-anchor="middle">EP2 · Multi-AZ · Lab</text>
    </g>
  </g>

  <!-- SHARED / EXTERNOS -->
  <g transform="translate(40, 100)">
    <rect width="1840" height="84" rx="4" fill="#FFFFFF" stroke="#D5DBDB" stroke-width="1.2"/>
    <rect x="0" y="0" width="360" height="22" rx="3" fill="#232F3E"/>
    <text x="180" y="15" font-size="9.5" font-weight="800" fill="#FFFFFF" text-anchor="middle">SERVICIOS SHARED / MANAGED (fuera de subnets)</text>

    <g transform="translate(30, 26)">
      <image href="{u['ecr']}" x="0" y="4" width="44" height="44"/>
      <text x="56" y="20" class="sec-title">Amazon ECR</text>
      <text x="56" y="35" class="sec-meta">5 repos Docker ARM64</text>
      <rect x="56" y="40" width="175" height="17" rx="2" fill="#EBF5FF" stroke="#A4CAFE"/>
      <text x="143" y="52" font-size="8.5" font-weight="700" fill="#1E429F" text-anchor="middle">frontend + 4 microservicios</text>
    </g>

    <g transform="translate(420, 26)">
      <image href="{u['cw']}" x="0" y="4" width="44" height="44"/>
      <text x="56" y="20" class="sec-title">Amazon CloudWatch</text>
      <text x="56" y="35" class="sec-meta">Container Insights (addon EKS)</text>
      <rect x="56" y="40" width="175" height="17" rx="2" fill="#F3FAF7" stroke="#BCF0DA"/>
      <text x="143" y="52" font-size="8.5" font-weight="700" fill="#03543F" text-anchor="middle">nodos · pods · métricas</text>
    </g>

    <g transform="translate(820, 26)">
      <image href="{u['hpa']}" x="0" y="4" width="44" height="44"/>
      <text x="56" y="20" class="sec-title">HPA (K8s)</text>
      <text x="56" y="35" class="sec-meta">Application Auto Scaling pods</text>
      <rect x="56" y="40" width="175" height="17" rx="2" fill="#FFF7ED" stroke="#FDBA74"/>
      <text x="143" y="52" font-size="8.5" font-weight="700" fill="#9A3412" text-anchor="middle">CPU 70% · min1 / max4</text>
    </g>

    <g transform="translate(1220, 26)">
      <image href="{u['eks']}" x="0" y="4" width="44" height="44"/>
      <text x="56" y="20" class="sec-title">EKS Control Plane</text>
      <text x="56" y="35" class="sec-meta">freshbox-cluster · k8s 1.34</text>
      <rect x="56" y="40" width="175" height="17" rx="2" fill="#FFF7ED" stroke="#FDBA74"/>
      <text x="143" y="52" font-size="8.5" font-weight="700" fill="#9A3412" text-anchor="middle">managed · LabRole</text>
    </g>

    <g transform="translate(1580, 26)">
      <rect width="44" height="44" rx="3" fill="#232F3E"/>
      <text x="22" y="27" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">LAB</text>
      <text x="56" y="20" class="sec-title">Learner Lab</text>
      <text x="56" y="35" class="sec-meta">LabRole / voclabs</text>
      <rect x="56" y="40" width="150" height="17" rx="2" fill="#F8FAFC" stroke="#D5DBDB"/>
      <text x="131" y="52" font-size="8.5" font-weight="700" fill="#545B64" text-anchor="middle">t4g.small Graviton</text>
    </g>
  </g>

  <!-- REGION + VPC
       Gaps Public↔App / App↔Data = 64px · corredor AZ = 380px
       AZ-a x=120..520 · AZ-b x=900..1300 · etiquetas solo en gaps/corredor -->
  <g transform="translate(40, 196)">
    <rect width="1840" height="1000" rx="4" fill="#FFFFFF" stroke="#879596" stroke-width="1.3" stroke-dasharray="6,4"/>
    <rect x="0" y="0" width="210" height="24" rx="2" fill="#232F3E"/>
    <text x="105" y="16" font-size="10.5" font-weight="700" fill="#FFFFFF" text-anchor="middle">AWS Region: us-east-1</text>

    <!-- Users → IGW (alineado al centro vertical del IGW: región y≈142) -->
    <g transform="translate(25, 94)">
      <rect width="105" height="96" rx="3" class="card-box"/>
      <image href="{u['user']}" x="28" y="10" width="48" height="48"/>
      <text x="52" y="72" font-size="11" font-weight="700" fill="#16191F" text-anchor="middle">Usuarios</text>
      <text x="52" y="86" font-size="9.5" font-weight="600" fill="#0073BB" text-anchor="middle">CRUD demo</text>
    </g>
    <path class="flow-line" d="M130 142 L204 142" stroke="#8C4FFF" stroke-width="2.2" marker-end="url(#arr-purple)"/>
    <g transform="translate(138, 116)">
      <rect width="54" height="20" rx="2" fill="#FAF5FF" stroke="#D8B4FE" class="side-pill"/>
      <text x="27" y="14" font-size="8.5" font-weight="800" fill="#6B21A8" text-anchor="middle">HTTP :80</text>
    </g>

    <!-- VPC -->
    <g transform="translate(190, 24)">
      <rect width="1380" height="950" rx="4" fill="#FCFAFF" stroke="#8C4FFF" stroke-width="1.8" stroke-dasharray="8,5"/>
      <rect x="18" y="-12" width="65" height="24" rx="2" fill="#8C4FFF"/>
      <text x="50" y="4" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">VPC</text>
      <text x="95" y="16" font-size="13" font-weight="800" fill="#581C87">freshbox-ep2 · 10.20.0.0/22 · 3 capas (Public / App / Data)</text>

      <!-- IGW (fuera de AZ) · bus superior + 2 caídas (fácil de inferir Multi-AZ) -->
      <g transform="translate(14, 70)">
        <rect width="90" height="96" rx="3" class="card-box"/>
        <image href="{u['igw']}" x="22" y="10" width="46" height="46"/>
        <text x="45" y="70" font-size="10.5" font-weight="700" fill="#16191F" text-anchor="middle">Internet GW</text>
        <text x="45" y="84" font-size="8.5" font-weight="600" fill="#8C4FFF" text-anchor="middle">edge VPC</text>
      </g>
      <!--
        Carril IGW dedicado y=48 (entre título VPC y techo de AZ y=78).
        Una barra horizontal → dos caídas verticales a ALB-a / ALB-b.
        Chips solo en el carril libre (nunca sobre cards).
      -->
      <path class="flow-line" d="M104 118 L104 48 L250 48" stroke="#8C4FFF" stroke-width="2.4"/>
      <path class="flow-line" d="M250 48 L1100 48" stroke="#8C4FFF" stroke-width="2.4"/>
      <!-- Caída AZ-a → techo ALB (x≈250) -->
      <path class="flow-line" d="M250 48 L250 146" stroke="#8C4FFF" stroke-width="2.4" marker-end="url(#arr-purple)"/>
      <!-- Caída AZ-b → techo ALB ENI (x≈1100) -->
      <path class="flow-line" d="M1100 48 L1100 146" stroke="#8C4FFF" stroke-width="2.4" marker-end="url(#arr-purple)"/>
      <!-- Chips en el bus (corredor / sobre cada caída), fuera de recursos -->
      <!-- Chip principal en corredor (libre de título VPC y de cards) -->
      <g transform="translate(620, 28)">
        <rect width="150" height="16" rx="2" fill="#FAF5FF" stroke="#D8B4FE" class="side-pill"/>
        <text x="75" y="12" font-size="8" font-weight="800" fill="#6B21A8" text-anchor="middle">IGW → ALB Multi-AZ</text>
      </g>
      <!-- Chips de caída en banda y=54..70 (entre bus y techo AZ), offset del stroke -->
      <g transform="translate(262, 54)">
        <rect width="64" height="16" rx="2" fill="#FAF5FF" stroke="#D8B4FE" class="side-pill"/>
        <text x="32" y="12" font-size="8" font-weight="800" fill="#6B21A8" text-anchor="middle">→ AZ-a</text>
      </g>
      <g transform="translate(1112, 54)">
        <rect width="64" height="16" rx="2" fill="#FAF5FF" stroke="#D8B4FE" class="side-pill"/>
        <text x="32" y="12" font-size="8" font-weight="800" fill="#6B21A8" text-anchor="middle">→ AZ-b</text>
      </g>

      <!-- ========== AZ-a (x=120, y=78 → deja carril IGW arriba) ========== -->
      <!-- Public y=36..196 · gap · App y=260..500 · gap · Data y=564..784 -->
      <g transform="translate(120, 78)">
        <rect width="400" height="860" rx="3" fill="#FFFFFF" stroke="#879596" stroke-width="1.2" stroke-dasharray="5,4"/>
        <text x="14" y="22" class="az-title">AZ us-east-1a</text>

        <g transform="translate(12, 36)">
          <rect width="376" height="160" rx="2" fill="#F7FCF7" stroke="#1E8900" stroke-width="1.3"/>
          <rect x="0" y="0" width="175" height="20" rx="2" fill="#1E8900"/>
          <text x="87" y="14" class="tag-text" text-anchor="middle">public-a 10.20.0.0/25</text>
          <rect x="250" y="3" width="115" height="18" rx="2" fill="#232F3E"/>
          <text x="307" y="15" class="tag-text" text-anchor="middle">SG-ALB</text>

          <g transform="translate(12, 32)">
            <rect width="210" height="112" rx="3" class="card-box"/>
            <image href="{u['alb']}" x="10" y="10" width="42" height="42"/>
            <text x="60" y="24" class="sec-title" font-size="12">ALB Ingress</text>
            <text x="60" y="40" class="sec-meta" font-size="10">internet-facing :80</text>
            <rect x="10" y="56" width="190" height="20" rx="2" fill="#F4F9FD" stroke="#0073BB"/>
            <text x="105" y="70" class="pill-text" fill="#0073BB" text-anchor="middle">AWS LB Controller</text>
            <rect x="10" y="80" width="190" height="20" rx="2" fill="#F7FCF7" stroke="#1E8900"/>
            <text x="105" y="94" class="pill-text" fill="#1E8900" text-anchor="middle">target-type: ip → pods</text>
          </g>

          <g transform="translate(236, 32)">
            <rect width="128" height="112" rx="3" class="card-box"/>
            <image href="{u['nat']}" x="42" y="10" width="44" height="44"/>
            <text x="64" y="68" font-size="10.5" font-weight="700" fill="#16191F" text-anchor="middle">NAT GW</text>
            <text x="64" y="84" font-size="8.5" font-weight="600" fill="#1E8900" text-anchor="middle">único (SPOF)</text>
            <rect x="10" y="90" width="108" height="16" rx="2" fill="#FFF3CD" stroke="#F9A825"/>
            <text x="64" y="102" font-size="8" font-weight="700" fill="#92400E" text-anchor="middle">egress privado</text>
          </g>
        </g>

        <!-- App AZ-a: solo workers/pods (ASG/NG va centrado entre AZ) -->
        <g transform="translate(12, 260)">
          <rect width="376" height="240" rx="2" fill="#F4F9FD" stroke="#0073BB" stroke-width="1.3"/>
          <rect x="70" y="-10" width="220" height="20" rx="2" fill="#0073BB"/>
          <text x="180" y="4" class="tag-text" text-anchor="middle">private-app-a 10.20.1.0/25</text>

          <g transform="translate(28, 36)">
            <rect width="320" height="180" rx="3" class="card-box"/>
            <image href="{u['eks']}" x="16" y="16" width="44" height="44"/>
            <text x="72" y="34" class="sec-title" font-size="12.5">Worker nodes · AZ-a</text>
            <text x="72" y="52" class="sec-meta" font-size="10.5">EC2 t4g.small · pods en esta AZ</text>
            <g transform="translate(16, 72)">
              <rect width="140" height="22" rx="2" fill="#FFF7ED" stroke="#FDBA74"/>
              <text x="70" y="15" class="pill-text" fill="#9A3412" text-anchor="middle">frontend + backends</text>
              <rect x="150" y="0" width="138" height="22" rx="2" fill="#F4F9FD" stroke="#0073BB"/>
              <text x="219" y="15" class="pill-text" fill="#0073BB" text-anchor="middle">ns: freshbox</text>
            </g>
            <rect x="16" y="110" width="288" height="22" rx="2" fill="#FDF2F2" stroke="#F8B4B4"/>
            <text x="160" y="125" font-size="9" font-weight="700" fill="#9B1C1C" text-anchor="middle">SG-EKS ← SG-ALB (pods)</text>
            <text x="160" y="158" font-size="9.5" fill="#545B64" text-anchor="middle">capacidad del NG Multi-AZ →</text>
          </g>
        </g>

        <!-- Data (gap 64px desde app) -->
        <g transform="translate(12, 564)">
          <rect width="376" height="220" rx="2" fill="#F8F9FA" stroke="#3F51B5" stroke-width="1.3"/>
          <rect x="70" y="-10" width="220" height="20" rx="2" fill="#3F51B5"/>
          <text x="180" y="4" class="tag-text" text-anchor="middle">private-data-a 10.20.2.0/25</text>

          <g transform="translate(12, 26)">
            <rect width="352" height="174" rx="3" class="card-box"/>
            <image href="{u['rds']}" x="12" y="14" width="48" height="48"/>
            <text x="72" y="30" class="sec-title" font-size="13">Amazon RDS MySQL</text>
            <text x="72" y="48" class="sec-meta" font-size="11">Primary · db.t4g.small · Multi-AZ</text>

            <g transform="translate(12, 72)">
              <rect width="155" height="22" rx="2" fill="#EEF2FF" stroke="#3F51B5"/>
              <text x="77" y="15" class="pill-text" fill="#312E81" text-anchor="middle">TCP :3306</text>
              <rect x="165" y="0" width="160" height="22" rx="2" fill="#FDF2F2" stroke="#F8B4B4"/>
              <text x="245" y="15" class="pill-text" fill="#9B1C1C" text-anchor="middle">storage encrypted</text>
            </g>
            <rect x="12" y="110" width="328" height="44" rx="2" fill="#FDF2F2" stroke="#F8B4B4"/>
            <text x="176" y="128" font-size="9" font-weight="700" fill="#9B1C1C" text-anchor="middle">SG-RDS: solo desde SG-EKS</text>
            <text x="176" y="144" font-size="8.5" font-weight="600" fill="#771D1D" text-anchor="middle">backup retention 7 días · sin IP pública</text>
          </g>
        </g>
      </g>

      <!-- ========== AZ-b (x=900 · corredor 520..900 = 380px · y=78) ========== -->
      <g transform="translate(900, 78)">
        <rect width="400" height="860" rx="3" fill="#FFFFFF" stroke="#879596" stroke-width="1.2" stroke-dasharray="5,4"/>
        <text x="14" y="22" class="az-title">AZ us-east-1b</text>

        <g transform="translate(12, 36)">
          <rect width="376" height="160" rx="2" fill="#F7FCF7" stroke="#1E8900" stroke-width="1.3"/>
          <rect x="0" y="0" width="195" height="20" rx="2" fill="#1E8900"/>
          <text x="97" y="14" class="tag-text" text-anchor="middle">public-b 10.20.0.128/25</text>

          <g transform="translate(90, 40)">
            <rect width="196" height="100" rx="3" class="card-box"/>
            <image href="{u['alb_res']}" x="76" y="8" width="44" height="44"/>
            <text x="98" y="68" font-size="11" font-weight="700" fill="#16191F" text-anchor="middle">ALB ENI</text>
            <text x="98" y="84" font-size="9.5" font-weight="600" fill="#1E8900" text-anchor="middle">Multi-AZ node</text>
          </g>
        </g>

        <!-- App AZ-b: solo workers/pods -->
        <g transform="translate(12, 260)">
          <rect width="376" height="240" rx="2" fill="#F4F9FD" stroke="#0073BB" stroke-width="1.3"/>
          <rect x="70" y="-10" width="230" height="20" rx="2" fill="#0073BB"/>
          <text x="185" y="4" class="tag-text" text-anchor="middle">private-app-b 10.20.1.128/25</text>

          <g transform="translate(28, 36)">
            <rect width="320" height="180" rx="3" class="card-box"/>
            <image href="{u['eks']}" x="16" y="16" width="44" height="44"/>
            <text x="72" y="34" class="sec-title" font-size="12.5">Worker nodes · AZ-b</text>
            <text x="72" y="52" class="sec-meta" font-size="10.5">misma NG · pods en esta AZ</text>
            <g transform="translate(16, 72)">
              <rect width="288" height="22" rx="2" fill="#FFF7ED" stroke="#FDBA74"/>
              <text x="144" y="15" class="pill-text" fill="#9A3412" text-anchor="middle">Deployments + Services ClusterIP</text>
            </g>
            <rect x="16" y="110" width="288" height="22" rx="2" fill="#F4F9FD" stroke="#0073BB"/>
            <text x="160" y="125" font-size="9" font-weight="700" fill="#0073BB" text-anchor="middle">HPA escala pods en ambas AZ</text>
            <text x="160" y="158" font-size="9.5" fill="#545B64" text-anchor="middle">← capacidad del NG Multi-AZ</text>
          </g>
        </g>

        <g transform="translate(12, 564)">
          <rect width="376" height="220" rx="2" fill="#F8F9FA" stroke="#3F51B5" stroke-width="1.3"/>
          <rect x="70" y="-10" width="230" height="20" rx="2" fill="#3F51B5"/>
          <text x="185" y="4" class="tag-text" text-anchor="middle">private-data-b 10.20.2.128/25</text>

          <g transform="translate(12, 26)">
            <rect width="352" height="174" rx="3" class="card-box"/>
            <image href="{u['rds']}" x="12" y="14" width="48" height="48"/>
            <text x="72" y="30" class="sec-title" font-size="13">RDS Standby</text>
            <text x="72" y="48" class="sec-meta" font-size="11">Multi-AZ failover automático</text>
            <rect x="12" y="78" width="328" height="70" rx="2" fill="#EEF2FF" stroke="#C7D2FE"/>
            <text x="176" y="108" font-size="10" font-weight="700" fill="#312E81" text-anchor="middle">Réplica síncrona en AZ-b</text>
            <text x="176" y="128" font-size="9" fill="#545B64" text-anchor="middle">RPO ≈ 0 en failover planificado</text>
          </g>
        </g>
      </g>

      <!-- ============================================================ -->
      <!-- CONEXIONES (AZ top=78 → +30 vs layout anterior)               -->
      <!-- Public bottom=274 · App 338..578 · Data 642+ · Corredor 520..900 -->
      <!-- ============================================================ -->

      <!-- Marco spanning capas App (y=330..586, centro=458) -->
      <rect x="112" y="330" width="1196" height="256" rx="4" fill="none" stroke="#EC7211" stroke-width="2.2" stroke-dasharray="8,5"/>

      <!-- Card NG/ASG centrada en marco naranja (márgenes ≈28px) -->
      <g transform="translate(545, 358)">
        <rect width="330" height="200" rx="4" class="card-box" stroke="#EC7211" stroke-width="2"/>
        <rect x="0" y="0" width="330" height="28" rx="4" fill="#EC7211"/>
        <text x="165" y="19" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">Managed Node Group · Multi-AZ</text>

        <image href="{u['eks']}" x="90" y="42" width="56" height="56"/>
        <image href="{u['asg']}" x="184" y="42" width="56" height="56"/>

        <text x="165" y="118" font-size="12" font-weight="800" fill="#16191F" text-anchor="middle">freshbox-ep2-ng</text>
        <text x="165" y="136" font-size="10" fill="#545B64" text-anchor="middle">1 ASG region-bounded · spans AZ-a + AZ-b</text>

        <rect x="24" y="148" width="282" height="20" rx="2" fill="#FFF7ED" stroke="#FDBA74"/>
        <text x="165" y="162" font-size="9" font-weight="700" fill="#9A3412" text-anchor="middle">min 2 · desired 3 · max 4 · t4g.small ARM64</text>
        <rect x="24" y="172" width="282" height="18" rx="2" fill="#F3FAF7" stroke="#BCF0DA"/>
        <text x="165" y="185" font-size="8.5" font-weight="700" fill="#03543F" text-anchor="middle">EBS encrypted · SG-EKS · HPA pods</text>
      </g>

      <!-- NG → workers (altura media card = 458) · chips en hueco corredor -->
      <path class="flow-line" d="M545 458 L480 458" stroke="#EC7211" stroke-width="2.2" marker-end="url(#arr-orange)"/>
      <path class="flow-line" d="M875 458 L940 458" stroke="#EC7211" stroke-width="2.2" marker-end="url(#arr-orange)"/>
      <g transform="translate(482, 432)">
        <rect width="58" height="16" rx="2" fill="#FFFBF5" stroke="#EC7211" class="side-pill"/>
        <text x="29" y="12" font-size="7.5" font-weight="700" fill="#C05621" text-anchor="middle">nodos</text>
      </g>
      <g transform="translate(880, 432)">
        <rect width="58" height="16" rx="2" fill="#FFFBF5" stroke="#EC7211" class="side-pill"/>
        <text x="29" y="12" font-size="7.5" font-weight="700" fill="#C05621" text-anchor="middle">nodos</text>
      </g>

      <!-- ALB → workers (gap Public↔App 274..338) -->
      <path class="flow-line" d="M250 274 L250 338" stroke="#0073BB" stroke-width="2.2" marker-end="url(#arr-blue)"/>
      <g transform="translate(262, 296)">
        <rect width="88" height="18" rx="2" fill="#F4F9FD" stroke="#0073BB" class="side-pill"/>
        <text x="44" y="13" font-size="8" font-weight="700" fill="#0073BB" text-anchor="middle">ALB → pods</text>
      </g>
      <path class="flow-line" d="M1100 274 L1100 338" stroke="#0073BB" stroke-width="2.2" marker-end="url(#arr-blue)"/>
      <g transform="translate(1112, 296)">
        <rect width="88" height="18" rx="2" fill="#F4F9FD" stroke="#0073BB" class="side-pill"/>
        <text x="44" y="13" font-size="8" font-weight="700" fill="#0073BB" text-anchor="middle">ALB → pods</text>
      </g>

      <!-- Workers → RDS (gap App↔Data 578..642) -->
      <path class="flow-line" d="M320 578 L320 642" stroke="#3B48CC" stroke-width="2.2" marker-end="url(#arr-sync)"/>
      <g transform="translate(332, 598)">
        <rect width="100" height="18" rx="2" fill="#EEF2FF" stroke="#C7D2FE" class="side-pill"/>
        <text x="50" y="13" font-size="8" font-weight="700" fill="#312E81" text-anchor="middle">MySQL :3306</text>
      </g>
      <path class="flow-line" d="M1100 578 L1100 610 L820 610 L820 670 L520 670" stroke="#3B48CC" stroke-width="2.0" stroke-dasharray="5 3" marker-end="url(#arr-sync)"/>
      <g transform="translate(860, 586)">
        <rect width="160" height="18" rx="2" fill="#EEF2FF" stroke="#C7D2FE" class="side-pill"/>
        <text x="80" y="13" font-size="8" font-weight="700" fill="#312E81" text-anchor="middle">pods AZ-b → RDS primary</text>
      </g>

      <!-- RDS sync -->
      <path class="flow-line" d="M520 750 L900 750" stroke="#3B48CC" stroke-width="2.2" marker-start="url(#arr-sync)" marker-end="url(#arr-sync)"/>
      <g transform="translate(640, 718)">
        <rect width="140" height="20" rx="2" fill="#EEF2FF" stroke="#C7D2FE" class="side-pill"/>
        <text x="70" y="14" font-size="8.5" font-weight="800" fill="#312E81" text-anchor="middle">RDS Multi-AZ sync</text>
      </g>

      <!-- Egress NG → NAT: sube por corredor (x=710) hasta y=200 (altura NAT), sin cruzar bus IGW y=48 -->
      <path class="flow-line" d="M710 358 L710 200 L450 200" stroke="#EC7211" stroke-width="1.8" stroke-dasharray="6 4" marker-end="url(#arr-orange)"/>
      <g transform="translate(560, 178)">
        <rect width="150" height="18" rx="2" fill="#FFFBF5" stroke="#EC7211" class="side-pill"/>
        <text x="75" y="13" font-size="8" font-weight="700" fill="#C05621" text-anchor="middle">egress → NAT → ECR</text>
      </g>
    </g>

    <!-- Side legend -->
    <g transform="translate(1600, 40)">
      <rect width="250" height="900" rx="4" fill="#FFFFFF" stroke="#D5DBDB"/>
      <rect x="0" y="0" width="250" height="28" rx="3" fill="#232F3E"/>
      <text x="125" y="19" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">FLUJO + SG</text>

      <text x="16" y="56" font-size="12" font-weight="800" fill="#16191F">Flujos (conexiones)</text>
      <text x="16" y="78" font-size="10.5" fill="#545B64">1. Usuario → IGW → ALB (ambas AZ)</text>
      <text x="16" y="96" font-size="10.5" fill="#545B64">2. ALB → pods workers en cada AZ</text>
      <text x="16" y="114" font-size="10.5" fill="#545B64">3. 1 NG/ASG centrado → nodos AZ</text>
      <text x="16" y="132" font-size="10.5" fill="#545B64">4. Pods (ambas AZ) → RDS primary</text>
      <text x="16" y="150" font-size="10.5" fill="#545B64">5. RDS primary ↔ standby</text>
      <text x="16" y="168" font-size="10.5" fill="#545B64">6. NG → NAT → ECR</text>

      <text x="16" y="188" font-size="9.5" fill="#C05621">Patrón: ASG Multi-AZ = 1 icono entre AZ</text>

      <text x="16" y="200" font-size="12" font-weight="800" fill="#16191F">Security Groups</text>
      <rect x="16" y="212" width="218" height="90" rx="3" fill="#FDF2F2" stroke="#F8B4B4"/>
      <text x="28" y="234" font-size="10.5" font-weight="700" fill="#9B1C1C">sg-alb: 80/443 ← Internet</text>
      <text x="28" y="254" font-size="10.5" font-weight="700" fill="#9B1C1C">sg-eks: ← sg-alb</text>
      <text x="28" y="274" font-size="10.5" font-weight="700" fill="#9B1C1C">sg-rds: 3306 ← sg-eks</text>
      <text x="28" y="292" font-size="10" fill="#545B64">cadena Internet → App → Data</text>

      <text x="16" y="332" font-size="12" font-weight="800" fill="#16191F">CONFIRMADO (TF)</text>
      <text x="16" y="354" font-size="11" fill="#03543F">• RDS Multi-AZ + encrypted</text>
      <text x="16" y="374" font-size="11" fill="#03543F">• EBS nodos encrypted</text>
      <text x="16" y="394" font-size="11" fill="#03543F">• ECR ×5 + CW Insights</text>
      <text x="16" y="414" font-size="11" fill="#03543F">• Node Group 2–4</text>

      <rect x="16" y="444" width="218" height="110" rx="3" fill="#FFF3CD" stroke="#F9A825"/>
      <text x="28" y="468" font-size="11" font-weight="800" fill="#92400E">VALIDATION WARNINGS</text>
      <text x="28" y="490" font-size="10.5" fill="#78350F">• NAT único = SPOF egress</text>
      <text x="28" y="510" font-size="10.5" fill="#78350F">• ALB vía Ingress (no aws_lb)</text>
      <text x="28" y="530" font-size="10.5" fill="#78350F">• Réplicas lab = 1 (HPA≤4)</text>

      <text x="16" y="590" font-size="11" font-weight="700" fill="#16191F">Iconos oficiales AWS</text>
      <text x="16" y="610" font-size="10" fill="#545B64">Asset Package 07/2025</text>
      <text x="16" y="628" font-size="10" fill="#545B64">mismo estilo visual EP1</text>
      <text x="16" y="656" font-size="10" fill="#545B64">Gaps ≥64px · chips fuera de strokes</text>
    </g>
  </g>
</svg>
'''

html = f'''<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>FreshBox EP2 TO-BE · EKS + RDS Multi-AZ (iconos oficiales AWS)</title>
  <style>
    body {{ margin:0; padding:16px; background:#0d1117; color:#c9d1d9;
      font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif; }}
    header {{ max-width:1920px; margin:0 auto 12px; display:flex; justify-content:space-between; align-items:flex-end;
      border-bottom:1px solid #30363d; padding-bottom:10px; }}
    h1 {{ margin:0; font-size:1.25rem; color:#fff; }}
    .sub {{ margin:4px 0 0; font-size:0.85rem; color:#8b949e; }}
    .badge {{ background:#21262d; border:1px solid #30363d; color:#FF9900; padding:6px 10px; border-radius:6px; font-size:12px; font-weight:700; }}
    #stage {{ max-width:1920px; margin:0 auto; background:#F4F5F7; border-radius:8px; overflow:hidden; border:1px solid #30363d; }}
    #stage svg {{ display:block; width:100%; height:auto; }}
  </style>
</head>
<body>
  <header>
    <div>
      <h1>FreshBox SpA — TO-BE EP2 (EKS + RDS Multi-AZ)</h1>
      <p class="sub">Iconos oficiales AWS Architecture Icons 07/2025 · mismo patrón visual que EP1 <code>architecture-freshbox.svg</code></p>
    </div>
    <span class="badge">ARY1102 · Learner Lab</span>
  </header>
  <div id="stage">
{svg}
  </div>
</body>
</html>
'''

svg_path = ROOT / "architecture-freshbox-ep2.svg"
html_path = ROOT / "architecture-freshbox-ep2.html"
# also replace the simplified studio html as the primary viewer
viewer = ROOT / "aws-architecture.html"

svg_path.write_text(svg, encoding="utf-8")
html_path.write_text(html, encoding="utf-8")
viewer.write_text(html, encoding="utf-8")

print(f"Wrote {svg_path} ({svg_path.stat().st_size} bytes)")
print(f"Wrote {html_path} ({html_path.stat().st_size} bytes)")
print(f"Updated {viewer}")
