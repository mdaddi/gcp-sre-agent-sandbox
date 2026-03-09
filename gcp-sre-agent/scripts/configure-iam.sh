#!/bin/bash
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-}"
WORKLOAD_NAME="${1:-srelab}"
CURRENT_USER=$(gcloud config get-value account)

if [ -z "$PROJECT_ID" ]; then
  echo "Error: GCP_PROJECT_ID not set"
  exit 1
fi

echo "Configuring IAM for $PROJECT_ID..."

# Grant current user admin access
echo "Granting $CURRENT_USER admin access..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$CURRENT_USER" \
  --role="roles/container.admin" \
  --quiet --no-user-output-enabled || true

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$CURRENT_USER" \
  --role="roles/secretmanager.admin" \
  --quiet --no-user-output-enabled || true

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$CURRENT_USER" \
  --role="roles/monitoring.admin" \
  --quiet --no-user-output-enabled || true

# Bind GKE service account for Workload Identity
echo "Configuring Workload Identity..."
CLUSTER_NAME="$WORKLOAD_NAME-gke"

KSA_EMAIL="sre-agent@$PROJECT_ID.iam.gserviceaccount.com"

# Create service account if not exists
gcloud iam service-accounts create sre-agent \
  --display-name="SRE Agent Service Account" \
  --project=$PROJECT_ID \
  2>/dev/null || true

# Bind Workload Identity
gcloud iam service-accounts add-iam-policy-binding $KSA_EMAIL \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:$PROJECT_ID.svc.id.goog[pets/sre-agent]" \
  --project=$PROJECT_ID \
  --quiet --no-user-output-enabled || true

echo "IAM configuration complete."
