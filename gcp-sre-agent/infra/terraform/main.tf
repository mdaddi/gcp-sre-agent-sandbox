terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }

  # Uncomment after creating GCS bucket for remote state
  # backend "gcs" {
  #   bucket = "terraform-state-PROJECT_ID"
  #   prefix = "srelab/default"
  # }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "kubernetes" {
  host                   = module.gke.kubernetes_cluster_host
  token                  = module.gke.kubernetes_cluster_token
  cluster_ca_certificate = base64decode(module.gke.kubernetes_cluster_ca_certificate)
  depends_on             = [module.gke]
}

module "vpc" {
  source = "./modules/vpc"

  network_name    = "${var.workload_name}-network"
  subnet_pods     = "10.0.0.0/22"
  subnet_services = "10.0.4.0/24"
  region          = var.gcp_region
}

module "gke" {
  source = "./modules/gke"

  project_id                = var.gcp_project_id
  cluster_name              = "${var.workload_name}-gke"
  region                    = var.gcp_region
  network_name              = module.vpc.network_name
  subnet_name               = module.vpc.subnet_pods_name
  kubernetes_version        = var.kubernetes_version
  workload_identity_pool_id = "${var.gcp_project_id}.svc.id.goog"

  system_pool = {
    name         = "system"
    machine_type = "n2-standard-2"
    node_count   = 2
  }

  user_pool = {
    name         = "user"
    machine_type = "n2-standard-2"
    node_count   = 3
  }

  depends_on = [module.vpc]
}

module "artifact_registry" {
  source = "./modules/artifact-registry"

  project_id                = var.gcp_project_id
  region                    = var.gcp_region
  repository_id             = "${var.workload_name}-docker"
  format                    = "DOCKER"
  gke_service_account_email = module.gke.default_service_account_email
  developer_email           = var.developer_email
}

module "secret_manager" {
  source = "./modules/secret-manager"

  project_id = var.gcp_project_id
  secrets = {
    "mongodb-password" : var.mongodb_password
    "rabbitmq-password" : var.rabbitmq_password
  }
  gke_service_account_email = module.gke.default_service_account_email
}

module "logging" {
  source = "./modules/logging"

  project_id   = var.gcp_project_id
  region       = var.gcp_region
  sink_name    = "${var.workload_name}-sink"
  dataset_name = "${replace(var.workload_name, "-", "_")}_logs"
  filter       = "resource.type=\"k8s_container\" OR resource.type=\"k8s_pod\""
}

module "monitoring" {
  source = "./modules/monitoring"

  project_id     = var.gcp_project_id
  region         = var.gcp_region
  workspace_name = "${var.workload_name}-metrics"
  cluster_name   = module.gke.cluster_name
  webhook_url    = var.webhook_url
}

module "iam" {
  source = "./modules/iam"

  project_id                = var.gcp_project_id
  cluster_name              = module.gke.cluster_name
  region                    = var.gcp_region
  workload_identity_pool_id = "${var.gcp_project_id}.svc.id.goog"

  service_accounts = {
    "sre-agent" = {
      roles = [
        "roles/secretmanager.secretAccessor",
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter"
      ]
    }
    "app-service" = {
      roles = [
        "roles/secretmanager.secretAccessor"
      ]
    }
  }

  depends_on = [module.gke, module.secret_manager]
}
