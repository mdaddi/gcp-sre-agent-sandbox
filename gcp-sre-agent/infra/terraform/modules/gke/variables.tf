variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "workload_identity_pool_id" {
  type = string
}

variable "system_pool" {
  type = object({
    name         = string
    machine_type = string
    node_count   = number
  })
}

variable "user_pool" {
  type = object({
    name         = string
    machine_type = string
    node_count   = number
  })
}
