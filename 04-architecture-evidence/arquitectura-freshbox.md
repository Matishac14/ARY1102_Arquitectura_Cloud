# Arquitectura FreshBox EP1 (ARY1102)

Infraestructura **3 capas Multi-AZ** en `us-east-1`, workspace Terraform `clases`, alineada al Learner Lab (LabRole / LabInstanceProfile, `t4g.small`, key `vockey`).

## Diagrama — topología AWS

```mermaid
flowchart TB
  User(["Usuario navegador"])

  subgraph VPC["VPC 10.0.0.0/22"]
    direction TB

    subgraph Pub["Subredes públicas ×2 AZ"]
      IGW["IGW"]
      ALB["Application Load Balancer :80"]
      NAT["NAT Gateway ×1"]
    end

    subgraph PrivApp["Subredes privadas App ×2 AZ"]
      ASG["Auto Scaling Group<br/>min 2 / max 4 · t4g.small"]
      TG["Target Group :80<br/>health check /"]
    end

    subgraph PrivData["Subredes privadas Data ×2 AZ"]
      MYSQL["EC2 MariaDB :3306"]
      BACKUP["AWS Backup vault/plan"]
    end
  end

  ECR["Amazon ECR<br/>5 repos ARM64"]
  STATE["S3 tfstate + DynamoDB locks"]

  User -->|"http://…elb.amazonaws.com"| ALB
  ALB --> TG
  TG --> ASG
  ASG -->|"egress vía NAT"| NAT
  NAT --> IGW
  ASG -->|"docker pull"| ECR
  ASG -->|"TCP 3306"| MYSQL
  MYSQL --- BACKUP
  STATE -.->|"backend Terraform / GitHub Actions"| ASG
```

## Diagrama — tráfico de aplicación (por EC2 App)

```mermaid
flowchart LR
  ALB["ALB :80"] --> NGINX["nginx frontend :80"]

  NGINX -->|"GET /api/products"| GET["get-products :3001"]
  NGINX -->|"POST /api/products"| POST["create-product :3002"]
  NGINX -->|"PUT /api/products/:id"| PUT["update-product :3003"]
  NGINX -->|"DELETE /api/products/:id"| DEL["delete-product :3004"]

  GET & POST & PUT & DEL --> DB[("MariaDB<br/>freshbox")]
```

## Diagrama — flujo de despliegue

```mermaid
sequenceDiagram
  actor Dev as Alumno
  participant GH as GitHub Actions
  participant TF as Terraform 01
  participant ECR as ECR
  participant ASG as ASG EC2

  Note over Dev: Bootstrap 00 (local, una vez)<br/>S3 + DynamoDB

  Dev->>GH: workflow_dispatch full-deploy + DEPLOY
  GH->>TF: plan + apply (workspace clases)
  TF-->>GH: ALB URL / ASG / MySQL
  GH->>ECR: buildx linux/arm64 ×5 + push
  GH->>ASG: terminate InService → user-data deploy.sh
  ASG->>ECR: docker pull
  ASG-->>GH: targets healthy
  GH->>GH: smoke GET / y /api/products
```

## Security Groups (estado actual)

| SG | Ingress |
|----|---------|
| ALB | TCP **80** desde `0.0.0.0/0` |
| App | TCP **80** solo desde SG-ALB |
| Data | TCP **3306** solo desde SG-App |

> No hay listener HTTPS en el ALB: abrir siempre `http://`.

## Checklist de evidencia

Ver [README.md](./README.md) en esta misma carpeta (capturas consola + CRUD).
