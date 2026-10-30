# FreshBox SpA — Infraestructura Terraform (EP1 / ARY1102)

Arquitectura de **3 capas Multi-AZ** alineada al enunciado y a las restricciones de AWS Academy Learner Lab.

## Topologia

| Capa | Recursos | CIDR / notas |
|------|----------|--------------|
| Publica | 2 subredes, IGW, ALB, NAT GW | `10.0.0.0/25`, `10.0.0.128/25` |
| Privada App | 2 subredes, ASG EC2+Docker (min 2 / max 4) | `10.0.1.0/25`, `10.0.1.128/25` |
| Privada Data | 2 subredes, EC2 MySQL + AWS Backup | `10.0.2.0/25`, `10.0.2.128/25` |

VPC: `10.0.0.0/22` · Region: `us-east-1` · Instancias: `t4g.small` (ARM) · Perfil IAM: `LabInstanceProfile`

### Security Groups (matriz EP1)

- **ALB** → TCP **80** desde `0.0.0.0/0` (sin listener HTTPS)
- **App** → TCP **80** solo desde SG-ALB
- **Data** → TCP **3306** solo desde SG-App

Diagrama Mermaid: [`../04-architecture-evidence/arquitectura-freshbox.md`](../04-architecture-evidence/arquitectura-freshbox.md)

## Restricciones Learner Lab respetadas

- Sin creacion de roles/usuarios IAM (usa `LabRole` / `LabInstanceProfile`)
- Max 5 EC2 concurrentes en este diseno (ASG 2–4 + 1 MySQL) → bajo el tope de 9
- EBS gp3 cifrado, ≤ 100 GB
- Key pair `vockey` en us-east-1
- Un solo NAT Gateway (presupuesto del lab)

## Despliegue

### 0. Credenciales del Learner Lab (obligatorio)

En este entorno las credenciales **no vienen precargadas** en tu PC. Hay que copiarlas del lab en cada sesion:

1. Entra al **AWS Academy Learner Lab** y arranca el laboratorio.
2. Abre **AWS Details**.
3. Copia **Access key**, **Secret access key** y **Session token** (las tres).
4. En tu terminal del proyecto:

```bash
# Importante: usa source para exportar las variables en ESTA shell
source ./03-deployment-scripts/setup-lab-credentials.sh
aws sts get-caller-identity
```

Alternativa manual:

```bash
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."          # obligatorio en el lab
export AWS_DEFAULT_REGION="us-east-1"
export AWS_REGION="us-east-1"
aws sts get-caller-identity
```

- **CloudShell** (icono en la consola del lab): credenciales ya configuradas; no hace falta el paso anterior.
- Si ves `ExpiredToken` / `InvalidClientTokenId`: el token del lab expiro; vuelve a copiarlo desde AWS Details.

Sin este paso, `terraform plan/apply` no puede hablar con AWS.

### 1. Workspace Terraform `clases`

El state de la asignatura vive en el workspace **`clases`** (ya creado en este repo). No uses `default` para el lab.

```bash
./03-deployment-scripts/use-workspace-clases.sh
# o:
cd 01-cloud-infrastructure
terraform workspace select clases   # o: terraform workspace new clases
terraform workspace show            # → clases
```

### 2. Aplicar infraestructura

```bash
cd 01-cloud-infrastructure
terraform init
terraform plan  -var-file=environments/clases/terraform.tfvars
terraform apply -var-file=environments/clases/terraform.tfvars
```

Anota los outputs:

```bash
terraform output alb_url
terraform output mysql_private_ip
terraform output ecr_repository_urls
```

### 3. Build + push de imagenes (ARM64)

Desde la raiz del repo (requiere Docker con build arm64):

```bash
./03-deployment-scripts/push-images-to-ecr.sh
```

### 4. Desplegar contenedores en el ASG

Si el user-data no alcanzo a pull (imagenes aun no existian):

```bash
./03-deployment-scripts/deploy-docker-services.sh
```

O via Session Manager en cada instancia App:

```bash
sudo /opt/freshbox/deploy.sh
```

### 5. Validar CRUD

```bash
ALB=$(terraform -chdir=01-cloud-infrastructure output -raw alb_dns_name)
curl "http://$ALB/api/products"
```

## Destroy (ahorrar presupuesto)

```bash
cd 01-cloud-infrastructure
terraform destroy
```

Deten/elimina recursos al terminar la sesion del lab (NAT + EC2 consumen presupuesto rapido).

## Modulos

```
modules/
  network/                 VPC, 6 subredes, IGW
  routing/                 NAT, route tables
  security-groups/         ALB / App / Data
  load-balancer/           ALB + Target Group
  application-autoscaling/ Launch Template + ASG
  database-server/         EC2 MySQL + AWS Backup
  container-registries/    5 repositorios ECR
```
