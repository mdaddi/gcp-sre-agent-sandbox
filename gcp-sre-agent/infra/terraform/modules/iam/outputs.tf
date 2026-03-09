output "service_account_emails" {
  value = {
    for k, v in google_service_account.workload_identity : k => v.email
  }
  description = "Service account emails for Workload Identity binding"
}
