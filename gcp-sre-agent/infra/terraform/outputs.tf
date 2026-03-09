output "cluster_endpoint" {
  value       = module.gke.kubernetes_cluster_host
  description = "GKE cluster endpoint"
}

output "cluster_name" {
  value       = module.gke.cluster_name
  description = "GKE cluster name"
}

output "region" {
  value       = var.gcp_region
  description = "GCP region"
}

output "artifact_registry_url" {
  value       = module.artifact_registry.repository_url
  description = "Artifact Registry repository URL"
}

output "sre_agent_service_account_email" {
  value       = module.iam.service_account_emails["sre-agent"]
  description = "SRE Agent service account email"
}

output "logging_dataset_id" {
  value       = module.logging.dataset_id
  description = "BigQuery dataset for logs"
}

output "monitoring_dashboard_ids" {
  value       = module.monitoring.dashboard_ids
  sensitive   = false
  description = "Cloud Monitoring dashboards"
}

output "grafana_endpoint_command" {
  value       = "kubectl get svc -n cloudops grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
  description = "Command to get Grafana endpoint"
}

output "storefront_endpoint_command" {
  value       = "kubectl get svc -n cloudops store-front -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
  description = "Command to get Store Frontend endpoint"
}
