variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "GCP region (us-central1, us-east1, europe-west1)"
}

variable "workload_name" {
  type        = string
  default     = "srelab"
  description = "Workload name for resource naming"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.32"
  description = "Kubernetes version for GKE"
}

variable "mongodb_password" {
  type        = string
  sensitive   = true
  description = "MongoDB admin password"
}

variable "rabbitmq_password" {
  type        = string
  sensitive   = true
  description = "RabbitMQ admin password"
}

variable "developer_email" {
  type        = string
  description = "Developer email for Artifact Registry push permissions"
}

variable "webhook_url" {
  type        = string
  default     = ""
  description = "Webhook URL for alert notifications (optional)"
}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable Cloud Monitoring and dashboards"
}

variable "enable_grafana" {
  type        = bool
  default     = true
  description = "Enable Grafana deployment"
}

variable "environment" {
  type        = string
  default     = "sandbox"
  description = "Environment tag"
}

variable "cost_center" {
  type        = string
  default     = "engineering"
  description = "Cost center for billing tags"
}

variable "owner_team" {
  type        = string
  default     = "platform"
  description = "Owner team for resource management"
}
