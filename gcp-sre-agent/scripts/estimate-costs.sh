#!/bin/bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  GCP SRE Agent Sandbox: Cost Estimator                     ${NC}"
echo -e "${BLUE}============================================================${NC}"

# GCP Pricing constants (monthly)
GKE_CONTROL_PLANE=73
SYSTEM_NODES=140       # 2x n2-standard-2
USER_NODES=210         # 3x n2-standard-2
ARTIFACT_REGISTRY=5
SECRET_MANAGER=2
CLOUD_LOGGING=0        # First 50GB free
CLOUD_MONITORING=0     # GKE metrics free
CLOUD_TRACE=5
GRAFANA_SELF_HOSTED=0  # Runs on GKE
NETWORKING=5           # Cloud NAT, LB
ALERTING=5             # Pub/Sub, notifications
BIGQUERY=10            # Log sink storage

NODES_TOTAL=$((SYSTEM_NODES + USER_NODES))
INFRA_TOTAL=$((GKE_CONTROL_PLANE + NODES_TOTAL + ARTIFACT_REGISTRY + SECRET_MANAGER + CLOUD_TRACE + NETWORKING + ALERTING + BIGQUERY))
GEMINI_API=20
TOTAL_WITH_GEMINI=$((INFRA_TOTAL + GEMINI_API))

echo -e "\n${BLUE}GCP Monthly Cost Breakdown:${NC}"
echo -e "  GKE Control Plane:    \$$GKE_CONTROL_PLANE"
echo -e "  System Nodes (2x):    \$$SYSTEM_NODES"
echo -e "  User Nodes (3x):      \$$USER_NODES"
echo -e "  Artifact Registry:    \$$ARTIFACT_REGISTRY"
echo -e "  Secret Manager:       \$$SECRET_MANAGER"
echo -e "  Cloud Logging:        \$$CLOUD_LOGGING (free tier)"
echo -e "  Cloud Monitoring:     \$$CLOUD_MONITORING (GKE free)"
echo -e "  BigQuery (logs):      \$$BIGQUERY"
echo -e "  Networking/NAT:       \$$NETWORKING"
echo -e "  Alerting/Pub/Sub:     \$$ALERTING"
echo -e "  Grafana (self-hosted): \$$GRAFANA_SELF_HOSTED"
echo -e "  ─────────────────────────────"
echo -e "  ${GREEN}Infrastructure Total:  \$$INFRA_TOTAL/month${NC}"
echo -e "  Gemini API (optional): \$$GEMINI_API/month"
echo -e "  ${GREEN}Total with Gemini:     \$$TOTAL_WITH_GEMINI/month${NC}"

echo -e "\n${BLUE}Cost Optimization Tips:${NC}"
echo -e "  - Delete resources when not in use: ${YELLOW}bash scripts/destroy.sh${NC}"
echo -e "  - Use spot/preemptible VMs for user node pool"
echo -e "  - Reduce node count during off-hours"
echo -e "  - Use committed use discounts for sustained usage"

DAILY=$((TOTAL_WITH_GEMINI / 30))
echo -e "\n${GREEN}Estimated daily cost: ~\$$DAILY/day${NC}"
echo -e "${GREEN}Estimated annual cost: ~\$$((TOTAL_WITH_GEMINI * 12))/year${NC}"
echo ""
