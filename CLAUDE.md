# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GCP SRE Agent Sandbox — a GCP-native SRE training lab with 10 breakable Kubernetes scenarios on GKE. Uses a Store Demo App (Vue.js frontend, Node.js/Rust/Go microservices, MongoDB, RabbitMQ) deployed to the `cloudops` namespace.

## Common Commands

```bash
# See all available targets
make help

# Deploy infrastructure and app (requires GCP_PROJECT_ID env var)
export GCP_PROJECT_ID=your-project-id
make deploy

# Validate deployment
make validate

# Tear down everything
make destroy

# Apply a breakable scenario
make break-oom

# Restore healthy state
make fix

# Watch pod status
make watch-pods

# Terraform operations
make tf-init
make tf-plan
make tf-apply

# Cost estimation
make estimate-costs
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
- Container images sourced from `ghcr.io/gcp-sre-agent/store-demo`
- Workload Identity is used for GCP service authentication (no key files)
- All app workloads deploy to the `cloudops` namespace
- Estimated cost: ~$450-470/month always-on, ~$16/day for demo usage
