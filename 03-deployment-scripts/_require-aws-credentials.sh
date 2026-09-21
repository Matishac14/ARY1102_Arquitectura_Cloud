#!/usr/bin/env bash
# Falla con mensaje claro si no hay credenciales AWS cargadas (Learner Lab).
set -euo pipefail

if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: AWS CLI no esta instalado."
  echo "Instala: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  exit 1
fi

if [[ -z "${AWS_ACCESS_KEY_ID:-}" && ! -f "${HOME}/.aws/credentials" ]]; then
  echo "ERROR: no hay credenciales AWS en este entorno."
  echo ""
  echo "Learner Lab (PC local):"
  echo "  1) En el lab, abre 'AWS Details'"
  echo "  2) Copia Access key, Secret key y Session token"
  echo "  3) Ejecuta:  source ./03-deployment-scripts/setup-lab-credentials.sh"
  echo ""
  echo "CloudShell del lab: las credenciales ya vienen cargadas; usa esa terminal."
  exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "ERROR: las credenciales AWS no funcionan (expiradas o incompletas)."
  echo "En Learner Lab el Session Token caduca: vuelve a copiarlo desde AWS Details."
  echo "  source ./03-deployment-scripts/setup-lab-credentials.sh"
  exit 1
fi
