resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.region
  initial_node_count = null

  remove_default_node_pool = true

  network         = var.network_name
  subnetwork      = var.subnet_name
  networking_mode = "VPC_NATIVE"

  cluster_secondary_range_name  = "pods"
  services_secondary_range_name = "services"

  workload_identity_config {
    workload_pool = var.workload_identity_pool_id
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      min_limit     = 1
      max_limit     = 10
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  enable_shielded_nodes = true

  labels = {
    environment = "sandbox"
  }
}

resource "google_container_node_pool" "system" {
  name       = var.system_pool.name
  cluster    = google_container_cluster.primary.name
  node_count = var.system_pool.node_count
  location   = var.region

  node_config {
    preemptible  = false
    machine_type = var.system_pool.machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"

    labels = {
      nodepool-type = "system"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "google_container_node_pool" "user" {
  name       = var.user_pool.name
  cluster    = google_container_cluster.primary.name
  node_count = var.user_pool.node_count
  location   = var.region

  node_config {
    preemptible  = false
    machine_type = var.user_pool.machine_type
    disk_size_gb = 100
    disk_type    = "pd-standard"

    labels = {
      nodepool-type = "user"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "kubernetes_storage_class" "standard_rwo" {
  depends_on = [google_container_node_pool.user]

  metadata {
    name = "standard-rwo"
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  parameters = {
    type             = "pd-standard"
    replication-type = "none"
  }
  allow_volume_expansion = true
}

resource "kubernetes_storage_class" "premium_rwo" {
  depends_on = [google_container_node_pool.user]

  metadata {
    name = "premium-rwo"
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  parameters = {
    type             = "pd-ssd"
    replication-type = "none"
  }
  allow_volume_expansion = true
}
