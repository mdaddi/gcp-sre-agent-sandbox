#!/bin/bash
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  GCP SRE Agent Sandbox: Troubleshooting                    ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

check_terraform() {
  echo -e "${BLUE}Checking Terraform state...${NC}"
  cd infra/terraform

  if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Terraform not initialized. Run: terraform init${NC}"
    return 1
  fi

  echo -e "${GREEN}  [PASS] Terraform initialized${NC}"
  terraform validate
  echo -e "${GREEN}  [PASS] Terraform config valid${NC}"
}

check_gcp_connection() {
  echo -e "${BLUE}Checking GCP connection...${NC}"

  if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}  [FAIL] gcloud CLI not installed${NC}"
    return 1
  fi

  PROJECT=$(gcloud config get-value project)
  echo -e "${GREEN}  [PASS] Connected to project: $PROJECT${NC}"
}

check_gke_cluster() {
  echo -e "${BLUE}Checking GKE cluster...${NC}"

  CLUSTERS=$(gcloud container clusters list --format='value(name)')

  if [ -z "$CLUSTERS" ]; then
    echo -e "${YELLOW}  No GKE clusters found.${NC}"
    return 1
  fi

  echo -e "${GREEN}  [PASS] Found clusters: $CLUSTERS${NC}"
}

check_kubectl() {
  echo -e "${BLUE}Checking kubectl...${NC}"

  if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}  [FAIL] kubectl not installed${NC}"
    return 1
  fi

  kubectl cluster-info &>/dev/null && echo -e "${GREEN}  [PASS] kubectl connected${NC}" || echo -e "${RED}  [FAIL] kubectl not connected${NC}"
}

check_kubernetes_resources() {
  echo -e "${BLUE}Checking Kubernetes resources...${NC}"

  kubectl get pods -n cloudops 2>/dev/null || echo -e "${YELLOW}  No cloudops namespace found${NC}"
}

# Main menu
echo "What would you like to check?"
echo "  1) Full system diagnosis"
echo "  2) Terraform state"
echo "  3) GCP connection"
echo "  4) GKE cluster"
echo "  5) kubectl"
echo "  6) Kubernetes resources"
echo "  q) Quit"
echo ""
read -p "Enter choice (1-6, q): " choice

case $choice in
  1) check_terraform && check_gcp_connection && check_gke_cluster && check_kubectl && check_kubernetes_resources ;;
  2) check_terraform ;;
  3) check_gcp_connection ;;
  4) check_gke_cluster ;;
  5) check_kubectl ;;
  6) check_kubernetes_resources ;;
  q) echo "Exiting."; exit 0 ;;
  *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
esac

echo ""
