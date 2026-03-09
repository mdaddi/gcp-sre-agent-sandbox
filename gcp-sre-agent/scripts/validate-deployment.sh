#!/bin/bash
set -euo pipefail

echo "=== GCP SRE Agent Sandbox Validation ==="

# Check cluster connectivity
echo "Checking cluster connectivity..."
kubectl cluster-info > /dev/null || exit 1
echo "  [PASS] Cluster reachable"

# Check nodes
echo "Checking nodes..."
NODES=$(kubectl get nodes --no-headers | wc -l)
if [ $NODES -lt 2 ]; then
  echo "  [FAIL] Found $NODES nodes, expected at least 2"
  exit 1
fi
echo "  [PASS] Found $NODES nodes"

# Check pets namespace
echo "Checking pets namespace..."
kubectl get namespace pets > /dev/null || exit 1
echo "  [PASS] Namespace exists"

# Check all pods running
echo "Checking pods..."
PENDING=$(kubectl get pods -n pets --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l)
if [ $PENDING -gt 0 ]; then
  echo "  [FAIL] Found $PENDING pending pods"
  kubectl get pods -n pets --field-selector=status.phase=Pending
  exit 1
fi
echo "  [PASS] No pending pods"

# Check services
echo "Checking services..."
kubectl get svc -n pets | grep -E 'store-front|store-admin' > /dev/null || exit 1
echo "  [PASS] Services deployed"

# Check LoadBalancer IPs
echo "Checking LoadBalancer endpoints..."
STORE_FRONT_IP=$(kubectl get svc store-front -n pets -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
if [ -z "$STORE_FRONT_IP" ]; then
  echo "  [INFO] Store front IP not yet assigned (this can take a few minutes)"
else
  echo "  [PASS] Store front: http://$STORE_FRONT_IP"
fi

echo ""
echo "=== All checks passed! ==="
