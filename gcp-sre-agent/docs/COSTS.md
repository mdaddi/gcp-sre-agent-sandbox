# GCP SRE Agent Sandbox - Cost Estimation

> Costs are estimates based on us-central1 pricing. Actual costs may vary.

## Quick Cost Summary

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| **GKE Control Plane** | $73 | Standard tier with SLA |
| **System Nodes (2x n2-standard-2)** | ~$140 | 2 vCPU, 8GB RAM each |
| **User Nodes (3x n2-standard-2)** | ~$210 | 2 vCPU, 8GB RAM each |
| **Artifact Registry** | ~$5 | Basic Docker storage |
| **Secret Manager** | ~$2 | 2 secrets, minimal operations |
| **Cloud Logging** | $0 | First 50GB/month free |
| **Cloud Monitoring** | $0 | GKE metrics included free |
| **BigQuery (log sink)** | ~$10 | Based on log volume |
| **Cloud NAT** | ~$5 | Outbound internet access |
| **Pub/Sub** | ~$5 | Alert notifications |
| **Grafana (self-hosted)** | $0 | Runs on GKE nodes |
| **Gemini API (optional)** | ~$20 | Based on query volume |
| **Total (without Gemini)** | **~$450** | |
| **Total (with Gemini)** | **~$470** | |

## Cost by Duration

| Duration | Estimated Cost |
|----------|---------------|
| 1 hour demo | ~$1-2 |
| 1 day | ~$16 |
| 1 month (always-on) | ~$470 |
| 1 year (always-on) | ~$5,640 |

## Cost Optimization Strategies

### For Development/Testing

1. **Delete when not in use**
   ```bash
   bash scripts/destroy.sh
   ```

2. **Use preemptible/spot VMs** for user node pool (~60-80% savings on compute)

3. **Reduce node count** during non-demo hours

4. **Disable optional components** (Grafana, Gemini API)

### For Sustained Usage

1. **Committed Use Discounts** - 1-year: ~28% savings, 3-year: ~52% savings on compute
2. **Right-size VMs** - Monitor actual usage and adjust machine types
3. **Log exclusions** - Already configured to exclude heartbeat logs

## GCP Free Tier Resources

| Service | Free Amount |
|---------|-------------|
| Cloud Logging | 50 GB/month ingestion |
| Cloud Monitoring | GKE system metrics |
| Secret Manager | 6 active secret versions |
| Artifact Registry | 500 MB storage |
| Pub/Sub | 10 GB/month |
| BigQuery | 10 GB storage, 1 TB queries/month |

## Monitoring Costs

Track spending in GCP Console:

1. Go to **Billing > Reports**
2. Filter by project and date range
3. Set up **Budget Alerts** at 50%, 75%, 100% thresholds
4. Use **Cost Table** for per-service breakdown

```bash
# View current billing status
gcloud billing accounts list
gcloud billing projects describe $GCP_PROJECT_ID
```

## Recommended Approach

Deploy when needed, destroy after demos. For a typical demo day:
- Deploy in the morning (~30 min)
- Run demos throughout the day
- Destroy at end of day
- **Estimated cost: ~$16/day**
