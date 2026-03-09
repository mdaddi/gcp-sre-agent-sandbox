variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "repository_id" {
  type = string
}

variable "format" {
  type    = string
  default = "DOCKER"
}

variable "gke_service_account_email" {
  type = string
}

variable "developer_email" {
  type = string
}
