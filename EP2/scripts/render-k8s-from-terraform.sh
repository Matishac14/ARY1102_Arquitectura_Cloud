#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA="$ROOT/01-cloud-infrastructure"
SRC="$ROOT/desarrolloapp/k8s"
OUT="$ROOT/desarrolloapp/k8s-rendered"

cd "$INFRA"
ACCOUNT_ID="$(terraform output -raw aws_account_id)"
RDS_HOST="$(terraform output -raw rds_endpoint)"
ALB_SG="$(terraform output -raw alb_security_group_id)"

echo "Account: $ACCOUNT_ID"
echo "RDS:     $RDS_HOST"
echo "ALB SG:  $ALB_SG"

rm -rf "$OUT"
mkdir -p "$OUT"
cp -R "$SRC/"* "$OUT/"

find "$OUT" -type f -name '*.yaml' -print0 | while IFS= read -r -d '' f; do
  sed -i.bak \
    -e "s/<ACCOUNT_ID>/${ACCOUNT_ID}/g" \
    -e "s/<RDS_ENDPOINT>/${RDS_HOST}/g" \
    "$f"
  rm -f "${f}.bak"
done

python3 - <<PY
from pathlib import Path
import re
p = Path("$OUT/ingress.yaml")
t = p.read_text()
sg = "$ALB_SG"
line = f"    alb.ingress.kubernetes.io/security-groups: {sg}\n"
if "alb.ingress.kubernetes.io/security-groups:" not in t:
    t = t.replace(
        "    alb.ingress.kubernetes.io/listen-ports:",
        line + "    alb.ingress.kubernetes.io/listen-ports:",
    )
else:
    t = re.sub(
        r"alb\.ingress\.kubernetes\.io/security-groups:.*",
        f"alb.ingress.kubernetes.io/security-groups: {sg}",
        t,
    )
p.write_text(t)
print("Ingress actualizado con security-groups")
PY

echo "Manifiestos listos en: $OUT"
