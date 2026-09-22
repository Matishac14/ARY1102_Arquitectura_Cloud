# Checklist de validación EP1 (demo)

Capturas sugeridas para el informe / defensa oral.

Diagrama de arquitectura: [`arquitectura-freshbox.md`](./arquitectura-freshbox.md)

## A. Infraestructura (consola AWS)

- [ ] VPC `freshbox-ep1-vpc` CIDR `10.0.0.0/22`
- [ ] 6 subredes (2 public / 2 private-app / 2 private-data) en 2 AZ
- [ ] Internet Gateway + NAT Gateway
- [ ] Route tables: public→IGW, private→NAT
- [ ] SG-ALB: **80** desde `0.0.0.0/0` (sin HTTPS en este diseño)
- [ ] SG-App: **80** origen SG-ALB
- [ ] SG-Data: **3306** origen SG-App
- [ ] ALB internet-facing + Target Group puerto 80 (targets healthy)
- [ ] ASG min 2 / max 4, instancias en 2 AZ
- [ ] EC2 MariaDB running + AWS Backup vault/plan
- [ ] ECR: 5 repositorios con imagen `latest` (ARM64)
- [ ] S3 tfstate + DynamoDB locks (bootstrap `00`)

## B. Servicio (navegador + curl)

```bash
export AWS_PROFILE=clases
terraform -chdir=01-cloud-infrastructure output -raw alb_url
# Abrir con http:// (no https)
```

- [ ] Frontend FreshBox carga (`GET /` → 200)
- [ ] Listado de productos (`GET /api/products` → 200)
- [ ] Crear producto (POST)
- [ ] Editar producto (PUT)
- [ ] Eliminar producto (DELETE)

## C. Script automático

```bash
export AWS_PROFILE=clases
./03-deployment-scripts/validate-ep1.sh
```

Debe terminar con `FAIL=0` y CRUD en verde.
