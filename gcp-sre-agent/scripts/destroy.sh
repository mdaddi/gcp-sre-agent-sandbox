#!/bin/bash
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-}"
WORKLOAD_NAME="${1:-srelab}"

if [ -z "$PROJECT_ID" ]; then
  echo "Error: GCP_PROJECT_ID not set"
  exit 1
fi

echo "!!! WARNING: This will DELETE all resources for $WORKLOAD_NAME in $PROJECT_ID !!!"
echo "Type 'DELETE' to confirm, or anything else to cancel:"
read -r confirm

if [ "$confirm" != "DELETE" ]; then
  echo "Cancelled."
  exit 0
fi

# Remove kubectl context
kubectl config delete-context gke_${PROJECT_ID}_us-central1_${WORKLOAD_NAME}-gke || true

# Destroy Terraform
cd infra/terraform
terraform destroy \
  -var="gcp_project_id=$PROJECT_ID" \
  -var="workload_name=$WORKLOAD_NAME" \
  -var="developer_email=user@example.com" \
  -var="mongodb_password=placeholder" \
  -var="rabbitmq_password=placeholder" \
  -auto-approve
cd ../..

echo "Destruction complete. Check GCP Console for resource deletion."
