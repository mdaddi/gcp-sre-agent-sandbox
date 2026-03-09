#!/bin/bash
set -e

echo "Setting up GCP SRE Agent Sandbox dev container..."

# Install additional tools
echo "Installing additional tools..."
apt-get update && apt-get install -y jq openssl bc

# GCP tools
echo "Configuring gcloud CLI..."
gcloud config set core/disable_usage_reporting true

# Kubernetes tools
echo "Installing Kubernetes tools..."
curl -sL https://github.com/kubectx/kubectx/releases/latest/download/kubectx -o /usr/local/bin/kubectx
curl -sL https://github.com/kubectx/kubectx/releases/latest/download/kubens -o /usr/local/bin/kubens
chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

# Git config
echo "Configuring Git..."
git config --global --add safe.directory /workspace

# Create shell aliases
echo "Creating shell aliases..."
cat >> ~/.bashrc << 'BASHRC'

# GCP aliases
alias glogin='gcloud auth application-default login'
alias gwho='gcloud auth list'
alias gproject='gcloud config get-value project'

# kubectl aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'
alias kwatch='kubectl get pods -n cloudops -w'

# Terraform aliases
alias tf='terraform'
alias tfplan='terraform plan'
alias tfapply='terraform apply'
alias tfdestroy='terraform destroy'
alias tffmt='terraform fmt -recursive'

# Demo aliases
alias deploy='bash scripts/deploy.sh'
alias destroy='bash scripts/destroy.sh'
alias validate='bash scripts/validate-deployment.sh'
alias estimate='bash scripts/estimate-costs.sh'
alias troubleshoot='bash scripts/troubleshoot.sh'

# Scenario aliases - break things
alias break-crash='kubectl apply -f k8s/scenarios/crash-loop.yaml'
alias break-oom='kubectl apply -f k8s/scenarios/oom-killed.yaml'
alias break-image='kubectl apply -f k8s/scenarios/image-pull-backoff.yaml'
alias break-cpu='kubectl apply -f k8s/scenarios/high-cpu.yaml'
alias break-pending='kubectl apply -f k8s/scenarios/pending-pods.yaml'
alias break-probe='kubectl apply -f k8s/scenarios/probe-failure.yaml'
alias break-network='kubectl apply -f k8s/scenarios/network-block.yaml'
alias break-config='kubectl apply -f k8s/scenarios/missing-config.yaml'
alias break-db='kubectl apply -f k8s/scenarios/mongodb-down.yaml'
alias break-service='kubectl apply -f k8s/scenarios/service-mismatch.yaml'

# Fix everything
alias fix-all='kubectl apply -f k8s/base/application.yaml && kubectl delete deployment cpu-stress-test unhealthy-service resource-hog misconfigured-service -n cloudops 2>/dev/null; kubectl delete networkpolicy deny-order-service -n cloudops 2>/dev/null; echo "All scenarios fixed!"'

# Help
sre-help() {
  echo "=== GCP SRE Agent Sandbox ==="
  echo ""
  echo "Deployment:"
  echo "  deploy [name] [region]  - Deploy infrastructure"
  echo "  destroy [name]          - Destroy infrastructure"
  echo "  validate                - Validate deployment"
  echo "  estimate                - Estimate costs"
  echo "  troubleshoot            - Troubleshoot issues"
  echo ""
  echo "Scenarios (break things):"
  echo "  break-oom       - OOMKilled (memory exhaustion)"
  echo "  break-crash     - CrashLoopBackOff (startup failure)"
  echo "  break-image     - ImagePullBackOff (bad image)"
  echo "  break-cpu       - High CPU utilization"
  echo "  break-pending   - Pending pods (insufficient resources)"
  echo "  break-probe     - Failed liveness probe"
  echo "  break-network   - Network policy blocking"
  echo "  break-config    - Missing ConfigMap"
  echo "  break-db        - MongoDB down (cascading failure)"
  echo "  break-service   - Service selector mismatch"
  echo ""
  echo "  fix-all         - Restore healthy state"
}

BASHRC

echo ""
echo "Dev container setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: glogin (authenticate to GCP)"
echo "2. Set: export GCP_PROJECT_ID=your-project-id"
echo "3. Deploy: deploy srelab us-central1"
echo "4. Run: sre-help (for all commands)"
echo ""
