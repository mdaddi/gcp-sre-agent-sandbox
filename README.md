# GCP SRE Agent Sandbox

A Google Cloud Platform-native SRE training lab with breakable Kubernetes scenarios for practicing incident diagnosis and remediation using Gemini, Cloud Logging, and Cloud Monitoring.

## Architecture

- **GKE Cluster** with system + user node pools (VPC-native, Calico network policies)
- **Store Demo App** (Vue.js frontend, Node.js/Rust/Go microservices, MongoDB, RabbitMQ) deployed to `cloudops` namespace
- **10 Breakable Scenarios** for SRE training (OOM, CrashLoop, ImagePull, CPU, Pending, Probe, Network, Config, DB Down, Service Mismatch)
- **Observability Stack**: Cloud Monitoring, Cloud Logging, BigQuery log sink, Grafana, Google Managed Prometheus
- **Infrastructure as Code**: Terraform with 7 modular modules

## Prerequisites

- GCP project with billing enabled
- `gcloud`, `terraform`, `kubectl` installed
- Owner or Editor role on the GCP project

## Quick Start

```bash
# 1. Set your project
export GCP_PROJECT_ID=your-project-id

# 2. See all available targets
make help

# 3. Deploy everything
make deploy

# 4. Validate
make validate

# 5. Apply a failure scenario
make break-oom

# 6. Watch pods
make watch-pods

# 7. Restore healthy state
make fix

# 8. Tear down
make destroy
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

## Project Structure

```
gcp-sre-agent/
  infra/terraform/           # Infrastructure as Code (7 modules)
  k8s/base/                  # Healthy application manifests
  k8s/scenarios/             # 10 breakable failure scenarios
  scripts/                   # Deploy, destroy, validate, troubleshoot
  docs/                      # Architecture, prompts, setup guides
  .devcontainer/             # VS Code dev container config
```

## Estimated Costs

| Component | Monthly |
|-----------|---------|
| GKE (control plane + 5 nodes) | ~$423 |
| Managed services (BigQuery, NAT, Pub/Sub, AR, SM) | ~$27 |
| Gemini API (optional) | ~$20 |
| **Total (without Gemini)** | **~$450/month** |
| **Total (with Gemini)** | **~$470/month** |

| Duration | Estimated Cost |
|----------|---------------|
| 1 hour demo | ~$1-2 |
| 1 day | ~$16 |
| 1 month (always-on) | ~$470 |

Run `make estimate-costs` for a detailed breakdown. See [Cost Estimation](gcp-sre-agent/docs/COSTS.md) for optimization strategies.

## Documentation

- [Breakable Scenarios Guide](gcp-sre-agent/docs/BREAKABLE-SCENARIOS.md)
- [SRE Agent Prompts Library](gcp-sre-agent/docs/SRE-AGENT-PROMPTS.md)
- [Gemini Setup Guide](gcp-sre-agent/docs/GEMINI-SETUP.md)
- [Architecture Diagrams](gcp-sre-agent/docs/C4-ARCHITECTURE.md)
- [Cost Estimation](gcp-sre-agent/docs/COSTS.md)
- [Changelog](CHANGELOG.md)

## License

MIT
