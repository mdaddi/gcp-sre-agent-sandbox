#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
WORKLOAD_NAME="${1:-srelab}"
GCP_REGION="${2:-us-central1}"
PROJECT_ID="${GCP_PROJECT_ID:-}"

if [ -z "$PROJECT_ID" ]; then
  echo -e "${RED}Error: GCP_PROJECT_ID not set${NC}"
  echo "Set with: export GCP_PROJECT_ID=your-project-id"
  exit 1
fi

# Allowed regions
ALLOWED_REGIONS=("us-central1" "us-east1" "europe-west1")
if [[ ! " ${ALLOWED_REGIONS[@]} " =~ " ${GCP_REGION} " ]]; then
  echo -e "${RED}Error: Region must be one of: ${ALLOWED_REGIONS[*]}${NC}"
  exit 1
fi

echo -e "${GREEN}Starting deployment of $WORKLOAD_NAME to $GCP_REGION...${NC}"

# Verify tools
for tool in gcloud terraform kubectl; do
  if ! command -v $tool &> /dev/null; then
    echo -e "${RED}Error: $tool not installed${NC}"
    exit 1
  fi
done

# Authenticate
echo -e "${YELLOW}Authenticating to GCP...${NC}"
gcloud auth application-default login
gcloud config set project $PROJECT_ID

# Enable required APIs
echo -e "${YELLOW}Enabling required GCP APIs...${NC}"
gcloud services enable \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  pubsub.googleapis.com \
  bigquery.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  --project=$PROJECT_ID

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
cd infra/terraform
terraform init

# Terraform plan
echo -e "${YELLOW}Creating Terraform plan...${NC}"
terraform plan \
  -var="gcp_project_id=$PROJECT_ID" \
  -var="gcp_region=$GCP_REGION" \
  -var="workload_name=$WORKLOAD_NAME" \
  -var="developer_email=$(gcloud config get-value account)" \
  -var="mongodb_password=secure-password-$(openssl rand -hex 8)" \
  -var="rabbitmq_password=secure-password-$(openssl rand -hex 8)" \
  -out=tfplan

# Apply with confirmation
echo -e "${YELLOW}Ready to apply changes. Review the plan above (y/n)${NC}"
read -r confirm
if [[ "$confirm" != "y" ]]; then
  echo "Cancelled."
  rm tfplan
  cd ../..
  exit 0
fi

terraform apply tfplan
cd ../..

# Get cluster credentials
echo -e "${YELLOW}Configuring kubectl...${NC}"
gcloud container clusters get-credentials $WORKLOAD_NAME-gke \
  --region=$GCP_REGION \
  --project=$PROJECT_ID

# Verify cluster
echo -e "${YELLOW}Verifying cluster connectivity...${NC}"
kubectl cluster-info
kubectl get nodes

# Configure IAM bindings
echo -e "${YELLOW}Configuring IAM bindings...${NC}"
bash scripts/configure-iam.sh

# Deploy application
echo -e "${YELLOW}Deploying application...${NC}"
kubectl create namespace cloudops --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s/base/application.yaml
kubectl apply -f k8s/base/gmp-pod-monitors.yaml
kubectl apply -f k8s/base/grafana.yaml

# Wait for LoadBalancer IPs
echo -e "${YELLOW}Waiting for service endpoints...${NC}"
sleep 30
kubectl get svc -n cloudops

# Validation
bash scripts/validate-deployment.sh

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}Grafana: kubectl get svc -n cloudops grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'${NC}"
echo -e "${GREEN}Store Front: kubectl get svc -n cloudops store-front -o jsonpath='{.status.loadBalancer.ingress[0].ip}'${NC}"
