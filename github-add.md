# Git & GitHub CLI Commands Used

All `git` and `gh` commands used to build and manage this project.

## Initial Setup

```bash
# Initialize git repository
git init

# Set git user identity
git config user.name "Mahalingesh Daddi"
git config user.email "mdaddi@gmail.com"

# Create GitHub repository
gh repo create gcp-sre-agent-sandbox --public \
  --description "GCP-native SRE training lab with breakable Kubernetes scenarios for incident diagnosis and remediation" \
  --source=. --push=false

# Add remote origin
git remote add origin https://github.com/mdaddi/gcp-sre-agent-sandbox.git
```

## Staging & Committing

```bash
# Stage all project files
git add README.md CHANGELOG.md Makefile CLAUDE.md hi gcp-sre-agent/

# Stage specific files
git add gcp-sre-agent/docs/C4-ARCHITECTURE.md Makefile
git add CLAUDE.md gcp-sre-agent/k8s/base/application.yaml \
  gcp-sre-agent/k8s/scenarios/image-pull-backoff.yaml \
  gcp-sre-agent/k8s/scenarios/crash-loop.yaml \
  gcp-sre-agent/k8s/scenarios/oom-killed.yaml \
  gcp-sre-agent/docs/C4-ARCHITECTURE.md

# Stage all changes
git add -A

# Remove a tracked file
git rm hi

# Check status
git status

# View recent commits
git log --oneline

# View diff (staged and unstaged)
git diff
```

## Commits Made

```bash
# v1.0.0 - Initial release
git commit -m "Initial release v1.0.0: GCP SRE Agent Sandbox

GKE-based SRE training lab with 10 breakable Kubernetes failure scenarios,
7 Terraform modules, Store Demo App, and full observability stack.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

# Remove Azure/AKS references
git commit -m "Remove all Azure/AKS references, rebrand container images

Replaced ghcr.io/azure-samples/aks-store-demo with
ghcr.io/gcp-sre-agent/store-demo across all K8s manifests,
scenarios, architecture docs, and CLAUDE.md. Also converted
C4 Mermaid diagrams to standard flowchart syntax for GitHub
rendering compatibility.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

# Namespace rename
git commit -m "Rename namespace from pets to cloudops across entire project

Updated all K8s manifests, scenarios, Terraform modules, scripts,
and documentation to use the cloudops namespace.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

# Makefile help target + C4 restore
git commit -m "Restore C4 Mermaid syntax and add make help target

Reverted architecture diagrams back to C4Context/C4Container/
C4Component/C4Deployment syntax. Added self-documenting help
target with descriptions for all 22 Makefile targets.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

# Fix Mermaid rendering
git commit -m "Fix Mermaid diagrams: replace C4 syntax with standard graph TB

GitHub does not support C4 diagram types. Converted all 4 diagrams
to standard Mermaid graph/subgraph syntax for proper rendering.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

# Update all docs
git commit -m "Update all docs: make targets, cost alignment, Mermaid fix notes

- Updated README.md and inner README to use make targets throughout
- Added make help to quick start instructions
- Aligned cost estimates with COSTS.md (~\$450-470/month)
- Updated CLAUDE.md common commands to use make targets
- Updated CHANGELOG v1.1.0 with all recent changes
- Renamed doc link from C4 Architecture to Architecture Diagrams

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

## Tagging

```bash
# Create annotated tag for v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"

# Create annotated tag for v1.1.0
git tag -a v1.1.0 -m "Release v1.1.0"
```

## Pushing

```bash
# Initial push with upstream tracking and tags
git push -u origin main --tags

# Subsequent pushes
git push origin main
git push origin main --tags
```

## GitHub CLI Authentication

```bash
# Check auth status
gh auth status
```

## Summary

| Command | Usage Count | Purpose |
|---------|-------------|---------|
| `git init` | 1 | Initialize repository |
| `git config` | 2 | Set user name and email |
| `git add` | 7 | Stage files for commit |
| `git commit` | 6 | Create commits |
| `git tag` | 2 | Tag releases (v1.0.0, v1.1.0) |
| `git push` | 5 | Push to GitHub remote |
| `git status` | 4 | Check working tree status |
| `git log` | 1 | View commit history |
| `git rm` | 1 | Remove tracked file |
| `git remote add` | 1 | Add GitHub remote |
| `gh repo create` | 1 | Create GitHub repository |
| `gh auth status` | 1 | Verify GitHub CLI auth |
