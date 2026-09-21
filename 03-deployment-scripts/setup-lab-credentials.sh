#!/usr/bin/env bash
# Configura credenciales temporales de AWS Academy Learner Lab en tu shell.
#
# En el lab: AWS Details → copia Access key, Secret key y Session token.
# Luego ejecuta ESTE script con source (no ./) para que las vars queden en tu terminal:
#
#   source ./03-deployment-scripts/setup-lab-credentials.sh
#
set -euo pipefail

echo "=== AWS Academy Learner Lab — credenciales ==="
echo "Abre el lab → enlace 'AWS Details' → copia Access key ID, Secret access key y Session token."
echo ""

if [[ -n "${AWS_ACCESS_KEY_ID:-}" && -n "${AWS_SECRET_ACCESS_KEY:-}" && -n "${AWS_SESSION_TOKEN:-}" ]]; then
  echo "Ya hay variables AWS_* en el entorno. Se reutilizaran salvo que indiques otras."
  read -r -p "¿Reemplazar credenciales actuales? [y/N] " REPLACE
  if [[ ! "${REPLACE}" =~ ^[Yy]$ ]]; then
    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    export AWS_REGION="${AWS_REGION:-us-east-1}"
    aws sts get-caller-identity
    echo "OK — credenciales activas. Ya puedes correr terraform / scripts."
    return 0 2>/dev/null || exit 0
  fi
fi

read -r -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -r -s -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo ""
read -r -s -p "AWS Session Token: " AWS_SESSION_TOKEN
echo ""

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
export AWS_REGION="${AWS_REGION:-us-east-1}"

echo ""
echo "Validando con STS..."
if ! aws sts get-caller-identity; then
  echo "ERROR: credenciales invalidas o expiradas. Vuelve a copiarlas desde AWS Details."
  return 1 2>/dev/null || exit 1
fi

echo ""
echo "OK — region ${AWS_REGION}. En ESTA terminal ya puedes:"
echo "  cd 01-cloud-infrastructure && terraform init && terraform apply"
echo ""
echo "Nota: el Session Token del lab expira. Si falla auth, vuelve a ejecutar:"
echo "  source ./03-deployment-scripts/setup-lab-credentials.sh"
