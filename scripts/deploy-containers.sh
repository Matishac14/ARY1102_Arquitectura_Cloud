#!/usr/bin/env bash
# FreshBox SpA - Deploy contenedores en EC2 (EP1)
# Ejecutar DENTRO de EC2 APP via Session Manager, o usar 03-deployment-scripts/deploy-docker-services.sh
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ECR="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
DB_HOST="${DB_HOST:?Exporta DB_HOST con la IP privada del EC2 MySQL}"

aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR}"

for SVC in frontend get-products create-product update-product delete-product; do
  docker pull "${ECR}/freshbox-${SVC}:latest"
done

docker network create freshbox-net 2>/dev/null || true
docker rm -f frontend get-products create-product update-product delete-product 2>/dev/null || true

docker run -d --name get-products --network freshbox-net --restart unless-stopped \
  -e DB_HOST="${DB_HOST}" -e DB_USER=alumno -e DB_PASS=alumno123 -e DB_NAME=freshbox -e PORT=3001 \
  "${ECR}/freshbox-get-products:latest"

docker run -d --name create-product --network freshbox-net --restart unless-stopped \
  -e DB_HOST="${DB_HOST}" -e DB_USER=alumno -e DB_PASS=alumno123 -e DB_NAME=freshbox -e PORT=3002 \
  "${ECR}/freshbox-create-product:latest"

docker run -d --name update-product --network freshbox-net --restart unless-stopped \
  -e DB_HOST="${DB_HOST}" -e DB_USER=alumno -e DB_PASS=alumno123 -e DB_NAME=freshbox -e PORT=3003 \
  "${ECR}/freshbox-update-product:latest"

docker run -d --name delete-product --network freshbox-net --restart unless-stopped \
  -e DB_HOST="${DB_HOST}" -e DB_USER=alumno -e DB_PASS=alumno123 -e DB_NAME=freshbox -e PORT=3004 \
  "${ECR}/freshbox-delete-product:latest"

# Nombres alineados con nginx.conf (get-products, create-product, ...)
docker run -d --name frontend --network freshbox-net --restart unless-stopped \
  -p 80:80 \
  "${ECR}/freshbox-frontend:latest"

docker ps
echo "=== Deploy EP1 completado ==="
