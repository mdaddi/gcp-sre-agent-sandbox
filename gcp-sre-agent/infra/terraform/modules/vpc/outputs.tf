output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnet_pods_name" {
  value = google_compute_subnetwork.pods.name
}

output "subnet_services_name" {
  value = google_compute_subnetwork.services.name
}

output "subnet_pods_cidr" {
  value = google_compute_subnetwork.pods.ip_cidr_range
}
