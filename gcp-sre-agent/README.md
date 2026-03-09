# GCP SRE Agent Sandbox

A Google Cloud Platform-native SRE training lab with breakable Kubernetes scenarios for practicing incident diagnosis and remediation using Gemini, Cloud Logging, and Cloud Monitoring.

## Architecture

- **GKE Cluster** with system + user node pools (VPC-native, Calico network policies)
- **Store Demo App** (Vue.js frontend, Node.js/Rust/Go microservices, MongoDB, RabbitMQ) deployed to `cloudops` namespace
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
make deploy

# 3. Validate
make validate
```

### Break Things

```bash
# Apply a failure scenario
make break-oom

# Watch pods crash
make watch-pods

# Diagnose with Cloud Logging / Gemini
# "Why is order-service restarting?"

# Fix it
make fix
```

### Destroy

```bash
make destroy
```

### All Targets

```bash
make help
```

## Breakable Scenarios

| Scenario | Make Target | What Breaks |
|----------|------------|-------------|
| OOMKilled | `make break-oom` | Memory exhaustion crashes |
| CrashLoop | `make break-crash` | Application startup failure |
| ImagePullBackOff | `make break-image` | Invalid container image |
| High CPU | `make break-cpu` | Resource exhaustion |
| Pending Pods | `make break-pending` | Insufficient cluster resources |
| Probe Failure | `make break-probe` | Health check failure loop |
| Network Block | `make break-network` | NetworkPolicy blocks traffic |
| Missing Config | `make break-config` | Non-existent ConfigMap reference |
| MongoDB Down | `make break-db` | Cascading dependency failure |
| Service Mismatch | `make break-service` | Silent selector mismatch |

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
| Managed services | ~$27 |
| Gemini API (optional) | ~$20 |
| **Total (without Gemini)** | **~$450/month** |
| **Total (with Gemini)** | **~$470/month** |

Run `make estimate-costs` for detailed breakdown. See [docs/COSTS.md](docs/COSTS.md) for optimization strategies.

## Documentation

- [Breakable Scenarios Guide](docs/BREAKABLE-SCENARIOS.md)
- [SRE Agent Prompts Library](docs/SRE-AGENT-PROMPTS.md)
- [Gemini Setup Guide](docs/GEMINI-SETUP.md)
- [Architecture Diagrams](docs/C4-ARCHITECTURE.md)
- [Cost Estimation](docs/COSTS.md)
