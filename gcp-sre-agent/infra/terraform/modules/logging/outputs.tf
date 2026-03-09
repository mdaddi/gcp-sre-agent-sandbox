output "dataset_id" {
  value = google_bigquery_dataset.logs_dataset.dataset_id
}

output "sink_name" {
  value = google_logging_project_sink.k8s_logs.name
}
