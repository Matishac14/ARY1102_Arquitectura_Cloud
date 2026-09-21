#!/usr/bin/env bash
# Recrear infra FreshBox EP1 desde cero (workspace clases / Learner Lab).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="${ROOT_DIR}/01-cloud-infrastructure"

# shellcheck source=/dev/null
source "${ROOT_DIR}/03-deployment-scripts/_require-aws-credentials.sh"

echo "=== Workspace clases ==="
cd "${TF_DIR}"
terraform init -input=false
if terraform workspace list | grep -qE '(^|\*)[[:space:]]*clases$'; then
  terraform workspace select clases
else
  terraform workspace new clases
fi
echo "Activo: $(terraform workspace show)"

echo ""
read -r -p "Esto ELIMINA y recrea toda la infra en workspace clases. Continuar? [y/N] " OK
[[ "${OK}" =~ ^[Yy]$ ]] || { echo "Cancelado"; exit 1; }

echo ""
echo "=== 1/4 destroy ==="
terraform destroy -var-file=environments/clases/terraform.tfvars -auto-approve

echo ""
echo "=== 2/4 apply ==="
terraform apply -var-file=environments/clases/terraform.tfvars -auto-approve

echo ""
echo "=== 3/4 push ECR ==="
cd "${ROOT_DIR}"
./03-deployment-scripts/push-images-to-ecr.sh

echo ""
echo "=== 4/4 deploy App (recicla ASG) ==="
./03-deployment-scripts/deploy-docker-services.sh

echo ""
echo "=== Validacion ==="
./03-deployment-scripts/validate-ep1.sh || true
echo "ALB: $(terraform -chdir="${TF_DIR}" output -raw alb_url)"
