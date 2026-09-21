#!/usr/bin/env bash
# Selecciona (o crea) el workspace Terraform "clases" para el lab/asignatura.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="${ROOT_DIR}/01-cloud-infrastructure"

cd "${TF_DIR}"

if ! terraform workspace list 2>/dev/null | grep -qE '(^|\*)\s*clases$'; then
  echo "Creando workspace 'clases'..."
  terraform workspace new clases
else
  terraform workspace select clases
fi

echo "Workspace activo: $(terraform workspace show)"
echo "Siguiente (con credenciales del lab):"
echo "  terraform plan  -var-file=environments/clases/terraform.tfvars"
echo "  terraform apply -var-file=environments/clases/terraform.tfvars"
