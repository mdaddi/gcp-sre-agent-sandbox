# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GCP SRE Agent Sandbox — a GCP-native SRE training lab with 10 breakable Kubernetes scenarios on GKE. Uses a Store Demo App (Vue.js frontend, Node.js/Rust/Go microservices, MongoDB, RabbitMQ) deployed to the `pets` namespace.

## Common Commands

```bash
# Deploy infrastructure and app (requires GCP_PROJECT_ID env var)
export GCP_PROJECT_ID=your-project-id
bash gcp-sre-agent/scripts/deploy.sh srelab us-central1

# Validate deployment
bash gcp-sre-agent/scripts/validate-deployment.sh

# Tear down everything
bash gcp-sre-agent/scripts/destroy.sh srelab

# Apply a breakable scenario
kubectl apply -f gcp-sre-agent/k8s/scenarios/<scenario>.yaml

# Restore healthy state
kubectl apply -f gcp-sre-agent/k8s/base/application.yaml

# Terraform operations (from gcp-sre-agent/infra/terraform/)
terraform init
terraform plan -var="gcp_project_id=$GCP_PROJECT_ID" -var="gcp_region=us-central1" -var="workload_name=srelab"
terraform apply

# Cost estimation
bash gcp-sre-agent/scripts/estimate-costs.sh
```

## Architecture

The project lives under `gcp-sre-agent/`. Key layers:

- **Terraform IaC** (`infra/terraform/`): Root module in `main.tf` orchestrates 7 modules: `vpc`, `gke`, `artifact-registry`, `secret-manager`, `logging`, `monitoring`, `iam`. Modules pass outputs via dependency chain: vpc → gke → iam, gke → artifact-registry, gke → secret-manager.
- **K8s manifests** (`k8s/base/`): Healthy-state app manifests (`application.yaml`), Grafana (`grafana.yaml`), and GMP pod monitors (`gmp-pod-monitors.yaml`).
- **Breakable scenarios** (`k8s/scenarios/`): 10 YAML files that inject failures (OOM, CrashLoop, ImagePullBackOff, high CPU, pending pods, probe failure, network block, missing config, MongoDB down, service mismatch).
- **Scripts** (`scripts/`): `deploy.sh` (full deploy pipeline), `destroy.sh`, `validate-deployment.sh`, `configure-iam.sh`, `troubleshoot.sh`, `estimate-costs.sh`.

## Key Constraints

- Allowed GCP regions: `us-central1`, `us-east1`, `europe-west1`
- Terraform requires `>= 1.0`, Google provider `~> 5.0`, Kubernetes provider `~> 2.23`
- GKE runs Kubernetes 1.32 with VPC-native networking and Calico network policies
- Node pools: 2x `n2-standard-2` (system), 3x `n2-standard-2` (user)
- Container images sourced from `ghcr.io/azure-samples/aks-store-demo`
- Workload Identity is used for GCP service authentication (no key files)
- All app workloads deploy to the `pets` namespace
