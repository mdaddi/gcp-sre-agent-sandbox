output "kubernetes_cluster_host" {
  value       = "https://${google_container_cluster.primary.endpoint}"
  description = "GKE cluster host"
  sensitive   = true
}

output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "region" {
  value = var.region
}

output "kubernetes_cluster_ca_certificate" {
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  description = "Cluster CA certificate"
  sensitive   = true
}

output "kubernetes_cluster_token" {
  value     = data.google_client_config.default.access_token
  sensitive = true
}

output "default_service_account_email" {
  value = data.google_compute_default_service_account.default.email
}

output "workload_identity_pool_id" {
  value = var.workload_identity_pool_id
}

data "google_client_config" "default" {}

data "google_compute_default_service_account" "default" {
  project = var.project_id
}
