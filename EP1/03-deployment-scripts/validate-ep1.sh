#!/usr/bin/env bash
# Validacion EP1 FreshBox — infra + servicio (CRUD via ALB)
# Uso:
#   export AWS_PROFILE=clases
#   ./03-deployment-scripts/validate-ep1.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="${ROOT_DIR}/01-cloud-infrastructure"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
export AWS_DEFAULT_REGION="$REGION"

PASS=0
FAIL=0
WARN=0

ok()   { echo "  [OK]  $*"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $*"; FAIL=$((FAIL+1)); }
warn() { echo "  [WARN] $*"; WARN=$((WARN+1)); }
section() { echo ""; echo "=== $* ==="; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Falta comando: $1"; exit 1; }
}

need_cmd aws
need_cmd curl
need_cmd terraform
need_cmd python3

section "0. Credenciales y workspace"
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  bad "AWS no autentica. export AWS_PROFILE=clases y renueva Session Token si expiro."
  exit 1
fi
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
ARN=$(aws sts get-caller-identity --query Arn --output text)
ok "Cuenta $ACCOUNT ($ARN)"

WS=$(terraform -chdir="$TF_DIR" workspace show)
[[ "$WS" == "clases" ]] && ok "Workspace Terraform = clases" || bad "Workspace=$WS (esperado: clases)"

ALB_URL=$(terraform -chdir="$TF_DIR" output -raw alb_url)
ALB_DNS=$(terraform -chdir="$TF_DIR" output -raw alb_dns_name)
VPC_ID=$(terraform -chdir="$TF_DIR" output -raw vpc_id)
ASG=$(terraform -chdir="$TF_DIR" output -raw asg_name)
MYSQL_IP=$(terraform -chdir="$TF_DIR" output -raw mysql_private_ip)
ok "ALB=$ALB_DNS VPC=$VPC_ID MySQL=$MYSQL_IP"

section "1. Red Multi-AZ (VPC / subredes / IGW / NAT)"
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'length(Subnets)' --output text)
[[ "$SUBNETS" == "6" ]] && ok "6 subredes en la VPC" || bad "Subredes=$SUBNETS (esperado 6)"

IGW=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
  --query 'length(InternetGateways)' --output text)
[[ "$IGW" -ge 1 ]] && ok "Internet Gateway presente" || bad "Sin IGW"

NAT=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=available" \
  --query 'length(NatGateways)' --output text)
[[ "$NAT" -ge 1 ]] && ok "NAT Gateway available" || bad "Sin NAT available"

section "2. Security Groups (ALB → App → Data)"
SG_JSON=$(terraform -chdir="$TF_DIR" output -json security_group_ids)
SG_ALB=$(python3 -c "import json,sys; print(json.load(sys.stdin)['alb'])" <<<"$SG_JSON")
SG_APP=$(python3 -c "import json,sys; print(json.load(sys.stdin)['app'])" <<<"$SG_JSON")
SG_DATA=$(python3 -c "import json,sys; print(json.load(sys.stdin)['data'])" <<<"$SG_JSON")

alb80=$(aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$SG_ALB" \
  --query "length(SecurityGroupRules[?IsEgress==\`false\` && FromPort==\`80\`])" --output text)
[[ "$alb80" -ge 1 ]] && ok "SG-ALB permite TCP 80" || bad "SG-ALB sin regla 80"

app_from_alb=$(aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$SG_APP" \
  --query "length(SecurityGroupRules[?IsEgress==\`false\` && FromPort==\`80\` && ReferencedGroupInfo.GroupId=='$SG_ALB'])" --output text)
[[ "$app_from_alb" -ge 1 ]] && ok "SG-App: 80 solo desde SG-ALB" || bad "SG-App no referencia SG-ALB en 80"

data_from_app=$(aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$SG_DATA" \
  --query "length(SecurityGroupRules[?IsEgress==\`false\` && FromPort==\`3306\` && ReferencedGroupInfo.GroupId=='$SG_APP'])" --output text)
[[ "$data_from_app" -ge 1 ]] && ok "SG-Data: 3306 solo desde SG-App" || bad "SG-Data no referencia SG-App en 3306"

section "3. Alta disponibilidad (ALB + ASG Multi-AZ)"
DESIRED=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG" \
  --query 'AutoScalingGroups[0].DesiredCapacity' --output text)
INSERVICE=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG" \
  --query "length(AutoScalingGroups[0].Instances[?LifecycleState=='InService'])" --output text)
[[ "$DESIRED" -ge 2 ]] && ok "ASG desired=$DESIRED (>=2)" || bad "ASG desired=$DESIRED"
[[ "$INSERVICE" -ge 2 ]] && ok "Instancias InService=$INSERVICE" || warn "InService=$INSERVICE (puede estar escalando)"

TG_ARN=$(aws elbv2 describe-target-groups --names freshbox-ep1-tg-app \
  --query 'TargetGroups[0].TargetGroupArn' --output text)
HEALTHY=$(aws elbv2 describe-target-health --target-group-arn "$TG_ARN" \
  --query "length(TargetHealthDescriptions[?TargetHealth.State=='healthy'])" --output text)
[[ "$HEALTHY" -ge 1 ]] && ok "Targets healthy=$HEALTHY" || bad "Targets healthy=$HEALTHY (contenedores no listos → 502)"

section "4. ECR (5 imagenes)"
ECR_OK=1
for r in freshbox-frontend freshbox-get-products freshbox-create-product freshbox-update-product freshbox-delete-product; do
  n=$(aws ecr describe-images --repository-name "$r" --query 'length(imageDetails)' --output text 2>/dev/null || echo 0)
  if [[ "$n" -ge 1 ]]; then ok "ECR $r tiene $n imagen(es)"; else bad "ECR $r vacio (0 imagenes)"; ECR_OK=0; fi
done

section "5. MySQL / Backup"
MYSQL_ID=$(terraform -chdir="$TF_DIR" output -raw mysql_instance_id)
STATE=$(aws ec2 describe-instances --instance-ids "$MYSQL_ID" \
  --query 'Reservations[0].Instances[0].State.Name' --output text)
[[ "$STATE" == "running" ]] && ok "EC2 MySQL running ($MYSQL_IP)" || bad "EC2 MySQL state=$STATE"

VAULT=$(terraform -chdir="$TF_DIR" output -raw backup_vault_name)
aws backup describe-backup-vault --backup-vault-name "$VAULT" >/dev/null 2>&1 \
  && ok "AWS Backup vault $VAULT existe" || bad "Backup vault no encontrado"

section "6. CRUD via ALB (end-to-end)"
CODE_ROOT=$(curl -sS -o /tmp/freshbox_root.html -w "%{http_code}" --max-time 15 "$ALB_URL/" || echo 000)
[[ "$CODE_ROOT" == "200" ]] && ok "GET / → HTTP 200" || bad "GET / → HTTP $CODE_ROOT (esperado 200; si 502: falta push/deploy)"

CODE_GET=$(curl -sS -o /tmp/freshbox_products.json -w "%{http_code}" --max-time 15 "$ALB_URL/api/products" || echo 000)
if [[ "$CODE_GET" == "200" ]]; then
  COUNT=$(python3 -c "import json; print(len(json.load(open('/tmp/freshbox_products.json'))))")
  ok "GET /api/products → 200 ($COUNT productos)"
else
  bad "GET /api/products → HTTP $CODE_GET"
fi

if [[ "$CODE_GET" == "200" ]]; then
  CODE_POST=$(curl -sS -o /tmp/freshbox_post.json -w "%{http_code}" --max-time 15 \
    -X POST "$ALB_URL/api/products" -H 'Content-Type: application/json' \
    -d '{"nombre":"Validacion EP1","descripcion":"producto de prueba","precio":1000,"stock":1,"categoria":"Test"}' || echo 000)
  [[ "$CODE_POST" =~ ^(200|201)$ ]] && ok "POST /api/products → $CODE_POST" || bad "POST → HTTP $CODE_POST"

  NEW_ID=$(python3 -c "import json; print(json.load(open('/tmp/freshbox_post.json')).get('id',''))" 2>/dev/null || true)
  if [[ -n "${NEW_ID:-}" ]]; then
    CODE_PUT=$(curl -sS -o /tmp/freshbox_put.json -w "%{http_code}" --max-time 15 \
      -X PUT "$ALB_URL/api/products/$NEW_ID" -H 'Content-Type: application/json' \
      -d '{"nombre":"Validacion EP1 OK","descripcion":"actualizado","precio":1500,"stock":2,"categoria":"Test"}' || echo 000)
    [[ "$CODE_PUT" == "200" ]] && ok "PUT /api/products/$NEW_ID → 200" || bad "PUT → HTTP $CODE_PUT"

    CODE_DEL=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 \
      -X DELETE "$ALB_URL/api/products/$NEW_ID" || echo 000)
    [[ "$CODE_DEL" =~ ^(200|204)$ ]] && ok "DELETE /api/products/$NEW_ID → $CODE_DEL" || bad "DELETE → HTTP $CODE_DEL"
  else
    warn "No se obtuvo id del POST; se omite PUT/DELETE"
  fi
else
  warn "Se omite POST/PUT/DELETE hasta que GET funcione"
fi

section "Resumen"
echo "  OK=$PASS  FAIL=$FAIL  WARN=$WARN"
echo "  Frontend UI: $ALB_URL"
echo ""
if [[ "$ECR_OK" -eq 0 ]]; then
  echo "Siguiente paso obligatorio:"
  echo "  ./03-deployment-scripts/push-images-to-ecr.sh"
  echo "  ./03-deployment-scripts/deploy-docker-services.sh"
  echo "  ./03-deployment-scripts/validate-ep1.sh"
fi
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
