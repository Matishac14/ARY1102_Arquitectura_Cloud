#!/usr/bin/env bash
# Build imagenes FreshBox (linux/arm64) para t4g.small
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== Build ARM64 FreshBox ==="
docker build --platform linux/arm64 -t freshbox-frontend:latest ./microservicioFrontend
docker build --platform linux/arm64 -t freshbox-get-products:latest ./microserviciosBackend/get-products
docker build --platform linux/arm64 -t freshbox-create-product:latest ./microserviciosBackend/create-product
docker build --platform linux/arm64 -t freshbox-update-product:latest ./microserviciosBackend/update-product
docker build --platform linux/arm64 -t freshbox-delete-product:latest ./microserviciosBackend/delete-product
echo "=== Build completado ==="
