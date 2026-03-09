variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "workload_identity_pool_id" {
  type = string
}

variable "service_accounts" {
  type = map(object({
    roles = list(string)
  }))
}
