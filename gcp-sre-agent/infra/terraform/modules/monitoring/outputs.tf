output "dashboard_ids" {
  value = {
    main = google_monitoring_dashboard.main.id
  }
}

output "alert_policies" {
  value = {
    pod_restart = google_monitoring_alert_policy.pod_restart.id
    crashloop   = google_monitoring_alert_policy.crashloop.id
  }
}

output "pubsub_topic" {
  value = google_pubsub_topic.alerts.name
}
