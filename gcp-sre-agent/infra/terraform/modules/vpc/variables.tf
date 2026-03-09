variable "network_name" {
  type = string
}

variable "subnet_pods" {
  type    = string
  default = "10.0.0.0/22"
}

variable "subnet_services" {
  type    = string
  default = "10.0.4.0/24"
}

variable "region" {
  type = string
}
