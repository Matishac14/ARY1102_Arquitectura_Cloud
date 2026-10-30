#!/usr/bin/env bash
set -euo pipefail
CLUSTER="${CLUSTER_NAME:-freshbox-cluster}"
REGION="${AWS_REGION:-us-east-1}"

helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
helm repo update eks

kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml

VPC_ID="$(aws eks describe-cluster --name "$CLUSTER" --region "$REGION" --query cluster.resourcesVpcConfig.vpcId --output text)"

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$CLUSTER" \
  --set region="$REGION" \
  --set vpcId="$VPC_ID" \
  --set serviceAccount.create=true \
  --set enableShield=false \
  --set enableWaf=false \
  --set enableWafv2=false

kubectl -n kube-system rollout status deployment/aws-load-balancer-controller --timeout=180s
echo "ALB Controller listo"
