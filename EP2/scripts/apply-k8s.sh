#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFESTS="${1:-$ROOT/desarrolloapp/k8s-rendered}"

if [[ ! -d "$MANIFESTS" ]]; then
  echo "No existe $MANIFESTS — ejecuta: ./scripts/render-k8s-from-terraform.sh"
  exit 1
fi

kubectl apply -f "$MANIFESTS/namespace.yaml"
kubectl apply -f "$MANIFESTS/configmap.yaml"
kubectl apply -f "$MANIFESTS/secret.yaml"
kubectl apply -f "$MANIFESTS/frontend-deployment.yaml"
kubectl apply -f "$MANIFESTS/get-products-deployment.yaml"
kubectl apply -f "$MANIFESTS/create-product-deployment.yaml"
kubectl apply -f "$MANIFESTS/update-product-deployment.yaml"
kubectl apply -f "$MANIFESTS/delete-product-deployment.yaml"
kubectl apply -f "$MANIFESTS/ingress.yaml"
kubectl apply -f "$MANIFESTS/hpa.yaml"

kubectl -n freshbox wait --for=condition=available deployment --all --timeout=300s || true
kubectl -n freshbox get pods,svc,ingress,hpa
echo "DNS ALB:"
kubectl -n freshbox get ingress freshbox-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo
