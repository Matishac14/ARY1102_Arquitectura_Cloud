#!/usr/bin/env bash
# Build + push de las 5 imagenes a ECR (ARM64)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/03-deployment-scripts/_require-aws-credentials.sh"

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ECR="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo "=== Account: ${ACCOUNT_ID} | Region: ${REGION} ==="

"${ROOT_DIR}/03-deployment-scripts/build-container-images.sh"

aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${ECR}"

REPOS=(
  freshbox-frontend
  freshbox-get-products
  freshbox-create-product
  freshbox-update-product
  freshbox-delete-product
)

for REPO in "${REPOS[@]}"; do
  aws ecr describe-repositories --repository-names "${REPO}" --region "${REGION}" >/dev/null 2>&1 \
    || aws ecr create-repository --repository-name "${REPO}" --region "${REGION}" >/dev/null
  docker tag "${REPO}:latest" "${ECR}/${REPO}:latest"
  docker push "${ECR}/${REPO}:latest"
done

echo "=== Push completado ==="
echo "Siguiente: ./03-deployment-scripts/deploy-docker-services.sh"
