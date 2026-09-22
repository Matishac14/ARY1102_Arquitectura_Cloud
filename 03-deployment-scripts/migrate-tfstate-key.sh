#!/usr/bin/env bash
# Migra el state S3 del key duplicado (env:/clases/clases/...) al key correcto
# (env:/clases/01-cloud-infrastructure/...).
#
# Causa: el backend key no debe incluir el nombre del workspace; Terraform
# ya antepone env:/<workspace>/ cuando usas workspaces.
set -euo pipefail

BUCKET="${TF_STATE_BUCKET:-freshbox-ep1-tfstate-613895857683}"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
export AWS_DEFAULT_REGION="$REGION"

OLD_KEY="env:/clases/clases/01-cloud-infrastructure/terraform.tfstate"
NEW_KEY="env:/clases/01-cloud-infrastructure/terraform.tfstate"

echo "Bucket=$BUCKET"
echo "OLD=s3://${BUCKET}/${OLD_KEY}"
echo "NEW=s3://${BUCKET}/${NEW_KEY}"

if ! aws s3api head-object --bucket "$BUCKET" --key "$OLD_KEY" >/dev/null 2>&1; then
  echo "No hay objeto en la ruta vieja; nada que migrar."
  exit 0
fi

if aws s3api head-object --bucket "$BUCKET" --key "$NEW_KEY" >/dev/null 2>&1; then
  echo "La ruta nueva ya existe. No se sobreescribe."
  exit 0
fi

aws s3 cp "s3://${BUCKET}/${OLD_KEY}" "s3://${BUCKET}/${NEW_KEY}"
echo "Migracion OK. (Opcional) borra la ruta vieja desde la consola S3."
