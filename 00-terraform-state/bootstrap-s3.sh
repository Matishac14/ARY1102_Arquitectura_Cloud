#!/usr/bin/env bash
# Crea/configura el bucket S3 de tfstate SIN usar el resource aws_s3_bucket
# (el provider TF llama GetBucketObjectLockConfiguration y el SCP del lab lo deniega).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
export AWS_DEFAULT_REGION="$REGION"

if [[ -f "${ROOT}/terraform.tfvars" ]]; then
  BUCKET="$(awk -F'"' '/state_bucket_name/ {print $2; exit}' "${ROOT}/terraform.tfvars")"
else
  BUCKET=""
fi
BUCKET="${STATE_BUCKET_NAME:-${BUCKET:-}}"

if [[ -z "$BUCKET" || "$BUCKET" == *ACCOUNT_ID* ]]; then
  echo "Define state_bucket_name en terraform.tfvars (con tu Account ID) o STATE_BUCKET_NAME=..."
  exit 1
fi

echo "Region=$REGION Bucket=$BUCKET"

if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "Bucket ya existe."
else
  echo "Creando bucket..."
  if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET"
  else
    aws s3api create-bucket --bucket "$BUCKET" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi
fi

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-tagging --bucket "$BUCKET" --tagging 'TagSet=[
  {Key=Name,Value='"$BUCKET"'},
  {Key=Project,Value=freshbox-ep1},
  {Key=Course,Value=ARY1102},
  {Key=Purpose,Value=terraform-remote-state}
]'

echo "OK — bucket listo. Luego: terraform apply (solo DynamoDB locks)"
