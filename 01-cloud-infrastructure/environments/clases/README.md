# Workspace Terraform: `clases`

Entorno de la asignatura ARY1102 / AWS Academy Learner Lab.

## Crear / seleccionar (una vez)

```bash
cd 01-cloud-infrastructure
terraform workspace new clases    # solo la primera vez
terraform workspace select clases
terraform workspace show          # debe imprimir: clases
```

## Credenciales AWS (perfil `clases` / `default`)

**No** guardes Access Key / Secret / Session Token dentro del repo. Ponlas en tu home
o usa `export AWS_PROFILE=clases` (el tfvars versionado deja `aws_profile = ""` para
que GitHub Actions use Secrets).

`~/.aws/credentials`

```ini
[default]
aws_access_key_id=ASIAxxxx
aws_secret_access_key=xxxx
aws_session_token=xxxx

[clases]
aws_access_key_id=ASIAxxxx
aws_secret_access_key=xxxx
aws_session_token=xxxx
```

`~/.aws/config`

```ini
[default]
region = us-east-1

[profile clases]
region = us-east-1
```

Luego:

```bash
export AWS_PROFILE=clases
aws sts get-caller-identity
```

Terraform en local usa el perfil via `AWS_PROFILE=clases`. En GitHub Actions
`aws_profile` queda vacio y se usan los Secrets del Environment.

## Aplicar con este workspace

```bash
# Credenciales
export AWS_PROFILE=clases   # o source setup-lab-credentials.sh

# Desde cero (destroy + apply + ECR + deploy)
./03-deployment-scripts/recreate-from-zero.sh
```

Solo apply (si ya no hay restos conflictivos):

```bash
cd 01-cloud-infrastructure
terraform workspace select clases
terraform apply -var-file=environments/clases/terraform.tfvars
cd ..
./03-deployment-scripts/push-images-to-ecr.sh
./03-deployment-scripts/deploy-docker-services.sh
./03-deployment-scripts/validate-ep1.sh
```

El state de `clases` queda aislado del workspace `default`.
