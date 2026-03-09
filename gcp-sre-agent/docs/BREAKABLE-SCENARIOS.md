# Breakable Scenarios Guide

This guide explains each failure scenario available in the GCP SRE Agent sandbox for demonstrating diagnosis capabilities with Gemini and Cloud Logging.

## Quick Reference

| Scenario | File | What Breaks | Diagnosis Focus |
|----------|------|-------------|-----------------|
| OOMKilled | `oom-killed.yaml` | Memory exhaustion | OOM events, memory limits |
| CrashLoop | `crash-loop.yaml` | Startup failure | Exit codes, log analysis |
| ImagePullBackOff | `image-pull-backoff.yaml` | Bad image reference | Registry/image troubleshooting |
| High CPU | `high-cpu.yaml` | Resource exhaustion | Performance analysis |
| Pending Pods | `pending-pods.yaml` | Insufficient resources | Scheduling analysis |
| Probe Failure | `probe-failure.yaml` | Health check failure | Probe configuration |
| Network Block | `network-block.yaml` | Connectivity issues | Network policy analysis |
| Missing Config | `missing-config.yaml` | ConfigMap reference | Configuration troubleshooting |
| MongoDB Down | `mongodb-down.yaml` | Cascading dependency | Dependency tracing, root cause |
| Service Mismatch | `service-mismatch.yaml` | Silent networking failure | Endpoint/selector analysis |

## Scenario Details

---

### 1. OOMKilled - Out of Memory

**File:** `k8s/scenarios/oom-killed.yaml`

**What happens:**
- Deploys order-service with extremely low memory limits (16Mi)
- Pod starts, runs for a few seconds, then gets killed by OOM Killer
- Kubernetes restarts the pod, cycle repeats

**How to break:**
```bash
kubectl apply -f k8s/scenarios/oom-killed.yaml
```

**What to observe:**
```bash
kubectl get pods -n pets -w
kubectl describe pod -l app=order-service -n pets | grep -A 5 "Last State"
```

**Diagnosis prompts:**
- "Why is the order-service pod restarting repeatedly?"
- "I see OOMKilled events. What memory should I allocate?"
- "Diagnose the memory issues in the pets namespace"

**How to fix:**
```bash
kubectl apply -f k8s/base/application.yaml
```

---

### 2. CrashLoopBackOff - Application Crash

**File:** `k8s/scenarios/crash-loop.yaml`

**What happens:**
- Deploys product-service with a command that exits immediately
- Container starts, runs invalid command, exits with code 1
- Kubernetes keeps restarting, enters CrashLoopBackOff

**How to break:**
```bash
kubectl apply -f k8s/scenarios/crash-loop.yaml
```

**What to observe:**
```bash
kubectl get pods -n pets | grep product-service
kubectl logs -l app=product-service -n pets --previous
```

**Diagnosis prompts:**
- "Why is product-service in CrashLoopBackOff?"
- "Show me the logs for the crashing pods"
- "What's causing exit code 1 in my application?"

**How to fix:**
```bash
kubectl apply -f k8s/base/application.yaml
```

---

### 3. ImagePullBackOff - Invalid Image

**File:** `k8s/scenarios/image-pull-backoff.yaml`

**What happens:**
- Deploys makeline-service referencing a non-existent image tag
- Kubelet can't pull the image from registry
- Pod stays in ImagePullBackOff state

**How to break:**
```bash
kubectl apply -f k8s/scenarios/image-pull-backoff.yaml
```

**What to observe:**
```bash
kubectl get pods -n pets | grep makeline
kubectl describe pod -l app=makeline-service -n pets | grep -A 10 Events
```

**Diagnosis prompts:**
- "Why can't my pods start? I see ImagePullBackOff"
- "Help me troubleshoot the container image issue"
- "What's wrong with the makeline-service deployment?"

**How to fix:**
```bash
kubectl apply -f k8s/base/application.yaml
```

---

### 4. High CPU Utilization

**File:** `k8s/scenarios/high-cpu.yaml`

**How to break:**
```bash
kubectl apply -f k8s/scenarios/high-cpu.yaml
```

**What to observe:**
```bash
kubectl top pods -n pets
kubectl top nodes
```

**Diagnosis prompts:**
- "My application is slow. What's consuming all the CPU?"
- "Analyze CPU usage across my pods"

**How to fix:**
```bash
kubectl delete deployment cpu-stress-test -n pets
```

---

### 5. Pending Pods - Insufficient Resources

**File:** `k8s/scenarios/pending-pods.yaml`

**How to break:**
```bash
kubectl apply -f k8s/scenarios/pending-pods.yaml
```

**What to observe:**
```bash
kubectl get pods -n pets | grep resource-hog
kubectl describe pod -l app=resource-hog -n pets | grep -A 10 Events
```

**Diagnosis prompts:**
- "Why are my pods stuck in Pending?"
- "Analyze cluster capacity and pending pods"

**How to fix:**
```bash
kubectl delete deployment resource-hog -n pets
```

---

### 6. Failed Liveness Probe

**File:** `k8s/scenarios/probe-failure.yaml`

**How to break:**
```bash
kubectl apply -f k8s/scenarios/probe-failure.yaml
```

**What to observe:**
```bash
kubectl get pods -n pets -l app=unhealthy-service -w
kubectl describe pod -l app=unhealthy-service -n pets | grep -A 5 "Liveness"
```

**Diagnosis prompts:**
- "My pods keep restarting but the app seems fine"
- "What's wrong with my liveness probe configuration?"

**How to fix:**
```bash
kubectl delete deployment unhealthy-service -n pets
```

---

### 7. Network Policy Blocking

**File:** `k8s/scenarios/network-block.yaml`

**How to break:**
```bash
kubectl apply -f k8s/scenarios/network-block.yaml
```

**What to observe:**
```bash
kubectl exec -n pets deploy/store-front -- curl -s order-service:3000/health
# Should timeout or fail
```

**Diagnosis prompts:**
- "Why can't store-front reach order-service?"
- "What network policies are blocking my services?"

**How to fix:**
```bash
kubectl delete networkpolicy deny-order-service -n pets
```

---

### 8. Missing ConfigMap

**File:** `k8s/scenarios/missing-config.yaml`

**How to break:**
```bash
kubectl apply -f k8s/scenarios/missing-config.yaml
```

**What to observe:**
```bash
kubectl get pods -n pets | grep misconfigured
kubectl describe pod -l app=misconfigured-service -n pets | grep -A 10 Events
```

**Diagnosis prompts:**
- "My pod won't start. Says something about ConfigMap?"
- "Troubleshoot the ConfigMap reference error"

**How to fix:**
```bash
kubectl delete deployment misconfigured-service -n pets
```

---

### 9. MongoDB Down - Cascading Dependency Failure

**File:** `k8s/scenarios/mongodb-down.yaml`

**What happens:**
- Scales MongoDB to 0 replicas (database goes offline)
- makeline-service can't connect to MongoDB, starts failing health checks
- Orders queue in RabbitMQ but never get fulfilled
- Most realistic scenario: requires tracing dependency chain

**How to break:**
```bash
kubectl apply -f k8s/scenarios/mongodb-down.yaml
```

**What to observe:**
```bash
kubectl get deployment mongodb -n pets
kubectl get pods -n pets -l app=makeline-service
kubectl exec -n pets deploy/rabbitmq -- rabbitmqctl list_queues
```

**Diagnosis prompts:**
- "The app is up but orders aren't going through. What's wrong?"
- "Trace the dependency chain - what broke first?"

**How to fix:**
```bash
kubectl apply -f k8s/base/application.yaml
```

---

### 10. Service Selector Mismatch - Silent Networking Failure

**File:** `k8s/scenarios/service-mismatch.yaml`

**What happens:**
- Replaces order-service Service with wrong selector (`app: order-service-v2`)
- Pods are perfectly healthy but Service has zero endpoints
- Store-front loads fine, but placing an order fails silently

**How to break:**
```bash
kubectl apply -f k8s/scenarios/service-mismatch.yaml
```

**What to observe:**
```bash
kubectl get pods -n pets -l app=order-service        # Healthy!
kubectl get endpoints order-service -n pets           # Empty!
kubectl get svc order-service -n pets -o jsonpath='{.spec.selector}'
```

**Diagnosis prompts:**
- "The site loads but placing an order fails. Everything looks healthy though."
- "Why does the order-service have no endpoints?"
- "Compare the order-service Service selector to the actual pod labels"

**How to fix:**
```bash
kubectl apply -f k8s/base/application.yaml
```

---

## Demo Flow Suggestions

### Quick Demo (5 minutes)

1. Apply OOMKilled scenario
2. Show pods crashing in kubectl
3. Diagnose with Cloud Logging / Gemini
4. Apply fix and show recovery

### Comprehensive Demo (20 minutes)

1. **Introduction** - Show healthy application
2. **Break #1** - OOMKilled (resource issues)
3. **Break #2** - Network Policy (connectivity)
4. **Break #3** - MongoDB Down (cascading failure)
5. **Advanced** - Service Mismatch (subtle diagnosis)
6. **Cleanup** - Restore all scenarios

## Best Practices

- Always test scenarios in dev environment first
- Have baseline metrics before breaking things
- Document what you did and when for demos
- Keep fix commands ready
- Don't apply multiple breaking scenarios simultaneously
- Don't leave scenarios running unattended
