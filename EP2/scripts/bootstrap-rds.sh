#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/01-cloud-infrastructure"
HOST="$(terraform output -raw rds_endpoint)"
USER="${DB_USER:-alumno}"
PASS="${DB_PASS:-alumno123}"
echo "Cargando schema en $HOST ..."
mysql -h "$HOST" -u "$USER" -p"$PASS" < "$ROOT/desarrolloapp/init.sql"
echo "OK"
