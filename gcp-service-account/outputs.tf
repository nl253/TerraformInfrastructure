output "service_account" {
  value = google_service_account.service_account
}

output "binding" {
  value = tolist(google_project_iam_binding.binding)
}
