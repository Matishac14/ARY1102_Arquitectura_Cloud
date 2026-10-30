#!/usr/bin/env bash
# Atajo opcional: equivale a init + apply en 01-cloud-infrastructure
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/01-cloud-infrastructure"
export AWS_REGION="${AWS_REGION:-us-east-1}"

echo ">>> terraform init"
terraform init -input=false

echo ">>> terraform apply (infra + app)"
terraform apply -input=false -auto-approve

echo
echo "URL app:"
terraform output -raw app_url || true
echo
