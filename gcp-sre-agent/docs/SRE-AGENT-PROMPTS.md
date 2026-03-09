# SRE Agent Prompt Library

A comprehensive collection of prompts for GCP SRE diagnosis using Gemini in Cloud Logging, organized by SRE discipline.

> **Tip:** Start with open-ended prompts and let the investigation guide you. Follow up with targeted prompts to drill deeper.

---

## Table of Contents

- [Troubleshooting](#troubleshooting)
- [Monitoring & Observability](#monitoring--observability)
- [Incident Response](#incident-response)
- [Capacity Planning & Scaling](#capacity-planning--scaling)
- [Security & Compliance](#security--compliance)
- [Change Management](#change-management)
- [Performance Analysis](#performance-analysis)
- [Dependency & Service Health](#dependency--service-health)
- [Remediation & Actions](#remediation--actions)
- [Scheduled Tasks & Automation](#scheduled-tasks--automation)
- [Conversation Starters](#conversation-starters-non-technical)

---

## Troubleshooting

### General Triage

| Prompt | When to Use |
|--------|-------------|
| "Something is wrong with my application. Can you investigate?" | Great starting point |
| "Which pods in the pets namespace are not in a Running state?" | Quick status check |
| "Show me all warning and error events in the pets namespace from the last 30 minutes" | Event-level triage |
| "Are there any failed deployments or rollouts in progress?" | Catch stuck rollouts |

### Pod-Level Diagnosis

| Prompt | When to Use |
|--------|-------------|
| "Why is [pod-name] in CrashLoopBackOff?" | Direct pod investigation |
| "Show me the logs for pods that have restarted in the last hour" | Correlate restarts with logs |
| "What's the exit code and termination reason for the last failed container in order-service?" | Precise failure details |
| "Compare the running pod spec for order-service to its deployment spec" | Detect config drift |

### Networking Issues

| Prompt | When to Use |
|--------|-------------|
| "Can store-front reach order-service on port 3000?" | Service-to-service connectivity |
| "Are there any network policies blocking traffic in the pets namespace?" | Restrictive policies |
| "Why does the order-service Service have zero endpoints?" | Selector/label mismatches |
| "Show me DNS resolution results for mongodb inside the cluster" | Service discovery |

### Storage & Volume Issues

| Prompt | When to Use |
|--------|-------------|
| "Are there any PersistentVolumeClaims stuck in Pending?" | Storage provisioning failures |
| "Check if the MongoDB data volume is running low on space" | Disk pressure detection |

---

## Monitoring & Observability

### Cluster Health

| Prompt | When to Use |
|--------|-------------|
| "Give me an overall health report for my GKE cluster" | Executive summary |
| "What's the node status and condition for all nodes?" | Node-level health |
| "Are there any system pods that aren't healthy in kube-system?" | Control plane health |
| "Show me the cluster autoscaler status and recent scaling decisions" | Auto-scaling behavior |

### Application Metrics

| Prompt | When to Use |
|--------|-------------|
| "What's the current CPU and memory utilization for each pod in pets namespace?" | Real-time snapshot |
| "Are there any pods consistently running above 80% of their resource limits?" | About-to-break detection |
| "Show me container restart counts and trends over the last 24 hours" | Stability trending |

### Log Analysis

| Prompt | When to Use |
|--------|-------------|
| "Query the last 50 error-level logs from the order-service container" | Targeted log retrieval |
| "Show me log volume trends - are any services producing unusual amounts of logs?" | Log storm detection |
| "Correlate pod restart events with error logs from the same time window" | Root cause correlation |

---

## Incident Response

### First Response

| Prompt | When to Use |
|--------|-------------|
| "I just got paged - my application is down. What's happening?" | Incident triage |
| "What's the blast radius? Which services are affected?" | Impact assessment |
| "When did this issue start? Show me the timeline of events" | Establish timeline |

### Root Cause Analysis

| Prompt | When to Use |
|--------|-------------|
| "What was the root cause of the pod failures that started 20 minutes ago?" | Post-triage RCA |
| "Trace the dependency chain - what broke first and what was impacted downstream?" | Cascading failure analysis |
| "Compare the current state of my cluster to 1 hour ago - what's different?" | Diff-based investigation |

---

## Capacity Planning & Scaling

| Prompt | When to Use |
|--------|-------------|
| "Do I have enough cluster capacity to handle a 2x traffic increase?" | Load readiness |
| "Which nodes are most utilized and which have headroom?" | Capacity map |
| "Are my resource requests and limits set appropriately based on actual usage?" | Right-sizing |
| "What's the trend in resource utilization over the past week?" | Growth trajectory |

---

## Security & Compliance

| Prompt | When to Use |
|--------|-------------|
| "Are any containers running as root in the pets namespace?" | Security posture |
| "Are there any containers running without resource limits set?" | Best practice enforcement |
| "Show me the RBAC roles and bindings in the pets namespace" | Access control review |
| "Are any of my container images using the 'latest' tag?" | Image tagging audit |
| "Check if network policies exist for all services" | Network segmentation |

---

## Change Management

| Prompt | When to Use |
|--------|-------------|
| "What changed in my cluster in the last 10 minutes?" | Post-change verification |
| "Show me the rollout history for order-service" | Deployment tracking |
| "What image versions are running vs. what's defined in the deployment spec?" | Version drift |

---

## Performance Analysis

| Prompt | When to Use |
|--------|-------------|
| "Which service has the highest response latency right now?" | Latency hotspot |
| "Is there any CPU throttling happening on my pods?" | Throttling detection |
| "My application is slow. Identify the bottleneck - CPU, memory, network, or disk?" | Performance triage |

---

## Dependency & Service Health

| Prompt | When to Use |
|--------|-------------|
| "Map out the service dependencies in the pets namespace" | Topology discovery |
| "Is MongoDB healthy and accepting connections?" | Database check |
| "Is RabbitMQ running and are queues being consumed?" | Message broker health |
| "Which services depend on MongoDB and how would they be affected if it went down?" | Blast radius |

---

## Remediation & Actions

| Prompt | What It Does |
|--------|-------------|
| "Restart the order-service pods" | Rolling restart |
| "Scale product-service to 3 replicas" | Horizontal scaling |
| "Delete the cpu-stress-test deployment" | Remove rogue workloads |
| "Remove the deny-order-service network policy" | Unblock traffic |
| "Scale the mongodb deployment back to 1 replica" | Restore dependency |
| "Roll back the order-service deployment to the previous revision" | Rollback |

---

## Scheduled Tasks & Automation

| Prompt | Schedule | Purpose |
|--------|----------|---------|
| "Check GKE cluster health and alert if any node is NotReady" | Every 15 min | Node monitoring |
| "Monitor pod restarts in pets namespace" | Every 15 min | Restart detection |
| "Run a daily capacity report" | Daily at 8 AM | Capacity monitoring |
| "Check for pods in CrashLoopBackOff or ImagePullBackOff" | Every 30 min | Failure detection |

---

## Conversation Starters (Non-Technical)

| Prompt | Why It Works |
|--------|-------------|
| "My website is broken" | Discovers what "broken" means |
| "Customers are complaining that checkout is slow" | Business-language to technical |
| "Is my app ready for a big product launch tomorrow?" | Capacity + health in business terms |
| "What should I be worried about right now?" | Proactive risk assessment |

---

## Pro Tips

1. **Layer your prompts** - Start broad, then narrow, then act
2. **Use business language** - "checkout is slow" translates to pod metrics
3. **Ask "why" not "what"** - Yields better insight
4. **Request timelines** - "When did this start?" helps correlate events
5. **Combine signals** - "Correlate pod restarts with CPU spikes and recent deployments"
6. **Follow up naturally** - Build on previous answers
7. **Ask for prevention** - "How can I prevent this from happening again?"
