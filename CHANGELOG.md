# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-09

### Changed

- Renamed application namespace from `pets` to `cloudops` across all manifests, scripts, Terraform, and documentation
- Rebranded container images from `ghcr.io/azure-samples/aks-store-demo` to `ghcr.io/gcp-sre-agent/store-demo`
- Converted C4 Mermaid diagrams to standard flowchart syntax for GitHub rendering compatibility

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
- C4 architecture diagrams (context, container, component, deployment)
