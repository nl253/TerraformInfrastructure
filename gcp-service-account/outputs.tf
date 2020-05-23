output "service_account" {
  value = google_service_account.service_account
}

output "policies" {
  value = tolist(data.google_iam_policy.policy)
}
