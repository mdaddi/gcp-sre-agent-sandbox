variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "dataset_name" {
  type = string
}

variable "sink_name" {
  type = string
}

variable "filter" {
  type    = string
  default = "resource.type=\"k8s_container\" OR resource.type=\"k8s_pod\""
}
