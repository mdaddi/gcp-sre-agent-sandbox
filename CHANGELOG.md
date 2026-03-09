# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-09

### Changed

- Renamed application namespace from `pets` to `cloudops` across all manifests, scripts, Terraform, and documentation
- Rebranded container images from `ghcr.io/azure-samples/aks-store-demo` to `ghcr.io/gcp-sre-agent/store-demo`
- Converted Mermaid diagrams to standard `graph` syntax for GitHub rendering compatibility
- Updated all READMEs to use `make` targets instead of raw script commands
- Aligned cost estimates across README, inner README, and COSTS.md (~$450-470/month)

### Added

- Self-documenting `make help` target as default Makefile goal
- Help descriptions (`## comment`) on all 22 Makefile targets

## [1.0.0] - 2026-03-09

### Added

- GKE cluster with system (2x n2-standard-2) and user (3x n2-standard-2) node pools
- VPC-native networking with Calico network policies and Cloud NAT
- Store Demo App deployment (Vue.js, Node.js, Rust, Go, MongoDB, RabbitMQ) in `cloudops` namespace
- 7 Terraform modules: vpc, gke, artifact-registry, secret-manager, logging, monitoring, iam
- 10 breakable Kubernetes failure scenarios for SRE training:
  - OOMKilled, CrashLoop, ImagePullBackOff, High CPU, Pending Pods
  - Probe Failure, Network Block, Missing Config, MongoDB Down, Service Mismatch
- Observability stack: Cloud Monitoring, Cloud Logging, BigQuery log sink, Grafana, Google Managed Prometheus
- GMP PodMonitoring CRDs for metrics scraping
- Workload Identity integration for GCP service authentication
- Deployment scripts: deploy, destroy, validate, configure-iam, troubleshoot, estimate-costs
- Makefile with targets for all common operations
- VS Code dev container configuration
- SRE Agent prompts library and Gemini setup documentation
- Architecture diagrams (system context, container, component, deployment)
