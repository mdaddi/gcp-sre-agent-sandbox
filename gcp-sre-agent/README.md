# GCP SRE Agent Sandbox

A Google Cloud Platform-native SRE training lab with breakable Kubernetes scenarios for practicing incident diagnosis and remediation using Gemini, Cloud Logging, and Cloud Monitoring.

## Architecture

- **GKE Cluster** with system + user node pools (VPC-native, Calico network policies)
- **Store Demo App** (Vue.js frontend, Node.js/Rust/Go microservices, MongoDB, RabbitMQ)
- **10 Breakable Scenarios** for SRE training (OOM, CrashLoop, ImagePull, CPU, Pending, Probe, Network, Config, DB Down, Service Mismatch)
- **Observability Stack**: Cloud Monitoring, Cloud Logging, BigQuery log sink, Grafana, Google Managed Prometheus
- **Infrastructure as Code**: Terraform with 7 modular modules

## Quick Start

### Prerequisites

- GCP project with billing enabled
- `gcloud`, `terraform`, `kubectl` installed
- Owner or Editor role on the GCP project

### Deploy

```bash
# 1. Set your project
export GCP_PROJECT_ID=your-project-id

# 2. Deploy everything
bash scripts/deploy.sh srelab us-central1

# 3. Validate
bash scripts/validate-deployment.sh
```

### Break Things

```bash
# Apply a failure scenario
kubectl apply -f k8s/scenarios/oom-killed.yaml

# Watch pods crash
kubectl get pods -n cloudops -w

# Diagnose with Cloud Logging / Gemini
# "Why is order-service restarting?"

# Fix it
kubectl apply -f k8s/base/application.yaml
```

### Destroy

```bash
bash scripts/destroy.sh srelab
```

## Breakable Scenarios

| Scenario | Command | What Breaks |
|----------|---------|-------------|
| OOMKilled | `break-oom` | Memory exhaustion crashes |
| CrashLoop | `break-crash` | Application startup failure |
| ImagePullBackOff | `break-image` | Invalid container image |
| High CPU | `break-cpu` | Resource exhaustion |
| Pending Pods | `break-pending` | Insufficient cluster resources |
| Probe Failure | `break-probe` | Health check failure loop |
| Network Block | `break-network` | NetworkPolicy blocks traffic |
| Missing Config | `break-config` | Non-existent ConfigMap reference |
| MongoDB Down | `break-db` | Cascading dependency failure |
| Service Mismatch | `break-service` | Silent selector mismatch |

See [docs/BREAKABLE-SCENARIOS.md](docs/BREAKABLE-SCENARIOS.md) for detailed instructions.

## Project Structure

```
gcp-sre-agent/
  infra/terraform/           # Infrastructure as Code
    modules/
      vpc/                   # VPC, subnets, firewall, NAT
      gke/                   # GKE cluster, node pools, storage
      iam/                   # Service accounts, Workload Identity
      monitoring/            # Dashboards, alerts, Pub/Sub
      artifact-registry/     # Docker container registry
      secret-manager/        # Secrets storage
      logging/               # BigQuery log sink, exclusions
  k8s/
    base/                    # Healthy application manifests
    scenarios/               # 10 breakable failure scenarios
  scripts/                   # Deploy, destroy, validate, troubleshoot
  docs/                      # Architecture, prompts, setup guides
  .devcontainer/             # VS Code dev container config
```

## Estimated Costs

| Component | Monthly |
|-----------|---------|
| GKE (control plane + 5 nodes) | ~$423 |
| Managed services | ~$32 |
| Gemini API (optional) | ~$20 |
| **Total** | **~$475/month** |

Run `bash scripts/estimate-costs.sh` for detailed breakdown.

## Documentation

- [Breakable Scenarios Guide](docs/BREAKABLE-SCENARIOS.md)
- [SRE Agent Prompts Library](docs/SRE-AGENT-PROMPTS.md)
- [Gemini Setup Guide](docs/GEMINI-SETUP.md)
- [C4 Architecture Diagrams](docs/C4-ARCHITECTURE.md)
- [Cost Estimation](docs/COSTS.md)
