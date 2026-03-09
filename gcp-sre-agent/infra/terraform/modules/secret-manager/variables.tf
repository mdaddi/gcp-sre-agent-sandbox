variable "project_id" {
  type = string
}

variable "secrets" {
  type      = map(string)
  sensitive = true
}

variable "gke_service_account_email" {
  type = string
}
