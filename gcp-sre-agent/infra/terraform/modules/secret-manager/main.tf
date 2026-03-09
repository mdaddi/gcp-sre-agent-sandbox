resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  secret_id = each.key

  replication {
    automatic = true
  }

  labels = {
    environment = "sre-sandbox"
  }
}

resource "google_secret_manager_secret_version" "secret_versions" {
  for_each = var.secrets

  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value
}

resource "google_secret_manager_secret_iam_member" "gke_secret_accessor" {
  for_each = var.secrets

  secret_id = google_secret_manager_secret.secrets[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.gke_service_account_email}"
}
