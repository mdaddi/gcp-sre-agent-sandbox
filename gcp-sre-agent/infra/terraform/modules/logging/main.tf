resource "google_bigquery_dataset" "logs_dataset" {
  project       = var.project_id
  dataset_id    = var.dataset_name
  friendly_name = "SRE Sandbox Logs"
  description   = "Logs from GKE cluster"
  location      = "US"

  default_table_expiration_ms = 7776000000

  labels = {
    environment = "sre-sandbox"
  }
}

resource "google_logging_project_sink" "k8s_logs" {
  name        = var.sink_name
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.logs_dataset.dataset_id}"

  filter = var.filter

  unique_writer_identity = true
}

resource "google_bigquery_dataset_iam_member" "logs_sink_writer" {
  dataset_id = google_bigquery_dataset.logs_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.k8s_logs.writer_identity
}

resource "google_logging_project_bucket_config" "default" {
  project          = var.project_id
  location         = var.region
  bucket_id        = "_Default"
  enable_analytics = true
}

resource "google_logging_project_exclusion" "high_volume" {
  name        = "exclude-high-volume-logs"
  description = "Exclude high-volume logging to reduce costs"
  filter      = "resource.type=\"k8s_node\" AND jsonPayload.message=~\".*heartbeat.*\""
  disabled    = false
}
