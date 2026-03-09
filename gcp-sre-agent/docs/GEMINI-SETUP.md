# Google Cloud Gemini Setup: SRE Agent

## Overview

GCP provides AI-powered infrastructure diagnostics through **Gemini in Cloud Logging** and the **Gemini API**. This guide covers three approaches for SRE-style diagnosis.

## Approach 1: Manual Cloud Logging Queries

### Access Cloud Logging Console

```bash
# Query Cloud Logging from CLI
gcloud logging read "resource.type=k8s_pod AND resource.labels.namespace_name=pets" \
  --limit=50 \
  --format=json

# Query for specific errors
gcloud logging read "resource.type=k8s_container AND severity>=ERROR AND resource.labels.namespace_name=pets" \
  --limit=20 \
  --format=json

# Query for pod restart events
gcloud logging read "resource.type=k8s_pod AND jsonPayload.reason=BackOff" \
  --limit=20 \
  --format=json
```

### Cloud Console Steps
1. Go to **Logging > Logs Explorer**
2. Filter by `resource.type="k8s_container"` and `resource.labels.namespace_name="pets"`
3. Click **Analyze with Gemini** (if available in your region)

## Approach 2: Gemini Code Assist

Use GitHub Copilot or VS Code Gemini extension to analyze logs interactively.

### Example Workflow

```bash
# Get pod logs
kubectl logs -n pets -l app=order-service --tail=50

# Copy logs and ask Gemini: "Why is this pod crashing?"

# Get pod events
kubectl describe pod -l app=order-service -n pets

# Ask Gemini: "Analyze these Kubernetes events and identify the root cause"
```

## Approach 3: Automated Gemini API + Cloud Functions

### Architecture

```
Alert triggered in Cloud Monitoring
           |
    Cloud Pub/Sub topic
           |
    Cloud Function (triggered)
           |
    Query Cloud Logging API
           |
    Call Gemini API for analysis
           |
    Send analysis to Slack/webhook
```

### Setup Steps

1. **Create a Cloud Function** triggered by the `srelab-metrics-alerts` Pub/Sub topic
2. **Query Cloud Logging** for relevant pod/container logs
3. **Call Gemini API** with logs as context, asking for diagnosis
4. **Send results** to Slack, email, or a webhook

## Useful Cloud Logging Queries

### Find OOMKilled Pods
```
resource.type="k8s_container"
resource.labels.namespace_name="pets"
jsonPayload.reason="OOMKilled"
```

### Find CrashLoopBackOff
```
resource.type="k8s_pod"
resource.labels.namespace_name="pets"
jsonPayload.reason="BackOff"
```

### Find ImagePullBackOff
```
resource.type="k8s_pod"
resource.labels.namespace_name="pets"
jsonPayload.reason="Failed"
jsonPayload.message=~".*pull.*"
```

### Find High CPU Events
```
resource.type="k8s_node"
jsonPayload.message=~".*cpu.*pressure.*"
```

## Troubleshooting

### If Gemini is not available in your region
- Use manual kubectl + Cloud Logging queries
- No blocking issue for running scenarios
- All scenarios work without Gemini - it just adds AI-powered diagnosis

### If Cloud Logging is empty
- Verify the log sink is configured: `terraform output logging_dataset_id`
- Check that the GKE cluster has logging enabled
- Wait a few minutes for logs to propagate

## Resources

- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [Gemini API Documentation](https://cloud.google.com/docs/gemini/overview)
- [GKE Monitoring](https://cloud.google.com/kubernetes-engine/docs/how-to/monitoring)
- [Cloud Monitoring Alerting](https://cloud.google.com/monitoring/alerts)
