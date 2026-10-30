#!/usr/bin/env bash
# Despliega contenedores FreshBox en el ASG del Learner Lab.
#
# En Academy Learner Lab suele fallar:
#   - SSM SendCommand (instancias privadas sin agente Online)
#   - StartInstanceRefresh (deny por SCP de la org)
#
# Fallback: terminar instancias del ASG (sin bajar desired) para que
# ASG lance EC2 nuevas y el user-data ejecute /opt/freshbox/deploy.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/03-deployment-scripts/_require-aws-credentials.sh"

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
export AWS_DEFAULT_REGION="$REGION"
ASG_NAME="$(terraform -chdir="${ROOT_DIR}/01-cloud-infrastructure" output -raw asg_name)"
ALB_URL="$(terraform -chdir="${ROOT_DIR}/01-cloud-infrastructure" output -raw alb_url)"

echo "Verificando imagenes en ECR..."
MISSING=0
for r in freshbox-frontend freshbox-get-products freshbox-create-product freshbox-update-product freshbox-delete-product; do
  n="$(aws ecr describe-images --repository-name "$r" --query 'length(imageDetails)' --output text 2>/dev/null || echo 0)"
  echo "  $r: $n"
  if [ "$n" -lt 1 ] 2>/dev/null; then MISSING=1; fi
done
if [ "$MISSING" -eq 1 ]; then
  echo "ECR incompleto. Primero: ./03-deployment-scripts/push-images-to-ecr.sh"
  exit 1
fi

OLD_IDS="$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "${ASG_NAME}" \
  --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId' \
  --output text | tr '\t' ' ')"

if [ -z "${OLD_IDS}" ] || [ "${OLD_IDS}" = "None" ]; then
  echo "No hay instancias InService en ${ASG_NAME}"
  exit 1
fi
echo "Instancias actuales: ${OLD_IDS}"

SSM_ONLINE="$(aws ssm describe-instance-information \
  --query 'length(InstanceInformationList[?PingStatus==`Online`])' \
  --output text 2>/dev/null || echo 0)"

if [ "${SSM_ONLINE}" -ge 1 ] 2>/dev/null; then
  echo "Intentando deploy via SSM..."
  # shellcheck disable=SC2086
  COMMAND_ID="$(aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --instance-ids ${OLD_IDS} \
    --parameters 'commands=["sudo /opt/freshbox/deploy.sh"]' \
    --query 'Command.CommandId' \
    --output text)"
  echo "SSM CommandId: ${COMMAND_ID}"
  sleep 10
else
  echo "SSM no disponible (Online=${SSM_ONLINE}). Reciclando instancias del ASG..."
  for id in ${OLD_IDS}; do
    echo "  Terminando ${id}..."
    aws autoscaling terminate-instance-in-auto-scaling-group \
      --instance-id "${id}" \
      --no-should-decrement-desired-capacity >/dev/null
  done

  echo "Esperando nuevas instancias InService (5-10 min)..."
  i=1
  while [ "$i" -le 40 ]; do
    NOW="$(aws autoscaling describe-auto-scaling-groups \
      --auto-scaling-group-names "${ASG_NAME}" \
      --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId' \
      --output text | tr '\t' ' ')"
    COUNT=0
    for _ in ${NOW}; do COUNT=$((COUNT + 1)); done
    echo "  [${i}/40] InService=${COUNT} → ${NOW:-ninguna}"
    if [ "$COUNT" -ge 2 ] && [ "$i" -ge 8 ]; then
      STILL_OLD=0
      for old in ${OLD_IDS}; do
        case " ${NOW} " in
          *" ${old} "*) STILL_OLD=1 ;;
        esac
      done
      if [ "$STILL_OLD" -eq 0 ]; then
        echo "Instancias nuevas listas"
        break
      fi
    fi
    i=$((i + 1))
    sleep 15
  done
fi

echo "Esperando targets healthy en ALB (pull Docker/ECR)..."
TG_ARN="$(aws elbv2 describe-target-groups --names freshbox-ep1-tg-app \
  --query 'TargetGroups[0].TargetGroupArn' --output text)"
i=1
while [ "$i" -le 48 ]; do
  HEALTHY="$(aws elbv2 describe-target-health --target-group-arn "${TG_ARN}" \
    --query "length(TargetHealthDescriptions[?TargetHealth.State=='healthy'])" \
    --output text)"
  echo "  [${i}/48] healthy=${HEALTHY}"
  if [ "${HEALTHY}" -ge 1 ] 2>/dev/null; then
    break
  fi
  i=$((i + 1))
  sleep 15
done

echo ""
CODE="$(curl -sS -o /tmp/freshbox_products.json -w "%{http_code}" --max-time 20 "${ALB_URL}/api/products" || echo 000)"
echo "GET ${ALB_URL}/api/products → HTTP ${CODE}"
head -c 400 /tmp/freshbox_products.json 2>/dev/null; echo
echo ""
echo "UI: ${ALB_URL}"
echo "Validacion: ./03-deployment-scripts/validate-ep1.sh"
