resource "google_monitoring_dashboard" "main" {
  dashboard_json = jsonencode({
    displayName = "SRE Agent Sandbox"
    gridLayout = {
      widgets = [
        {
          title = "Pod CPU Usage"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/cpu/core_usage_time\" resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\""
                  }
                }
              }
            ]
          }
        },
        {
          title = "Pod Memory Usage"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/memory/used_bytes\" resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\""
                  }
                }
              }
            ]
          }
        }
      ]
    }
  })
}

resource "google_monitoring_alert_policy" "pod_restart" {
  display_name = "High Pod Restart Rate"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Pod restarts > 5 in 5 minutes"

    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/pod/container/restart_count\" resource.type=\"k8s_pod\" resource.labels.namespace_name=\"cloudops\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 5

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.webhook_url != "" ? [google_monitoring_notification_channel.webhook[0].name] : []
}

resource "google_monitoring_alert_policy" "crashloop" {
  display_name = "CrashLoopBackOff Detected"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Pod in CrashLoopBackOff"

    condition_threshold {
      filter          = "resource.type=\"k8s_pod\" resource.labels.namespace_name=\"cloudops\" metric.type=\"kubernetes.io/pod/phase\" AND metric.labels.phase=\"Failed\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.webhook_url != "" ? [google_monitoring_notification_channel.webhook[0].name] : []
}

resource "google_monitoring_notification_channel" "webhook" {
  count        = var.webhook_url != "" ? 1 : 0
  display_name = "SRE Agent Webhook"
  type         = "webhook_tokenauth"
  enabled      = true

  labels = {
    url = var.webhook_url
  }
}

resource "google_pubsub_topic" "alerts" {
  name = "${var.workspace_name}-alerts"
}

resource "google_monitoring_notification_channel" "pubsub" {
  display_name = "SRE Agent Pub/Sub"
  type         = "pubsub"
  enabled      = true

  labels = {
    channel_name = google_pubsub_topic.alerts.id
  }

  depends_on = [google_pubsub_topic.alerts]
}
