resource "google_service_account" "workload_identity" {
  for_each = var.service_accounts

  account_id   = each.key
  display_name = "Service account for ${each.key}"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  for_each = var.service_accounts

  service_account_id = google_service_account.workload_identity[each.key].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.workload_identity_pool_id}[cloudops/${each.key}]"
  ]
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = merge([
    for sa_name, sa_config in var.service_accounts : {
      for role in sa_config.roles : "${sa_name}-${role}" => {
        service_account = google_service_account.workload_identity[sa_name].email
        role            = role
      }
    }
  ]...)

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account}"
}
