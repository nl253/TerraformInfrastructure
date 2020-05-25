provider "google-beta" {
  project = "test-project-277710"
}

resource "google_service_account" "service_account" {
  lifecycle {
    prevent_destroy = true
  }
  account_id   = replace(lower(var.name), " ", "-")
  display_name = var.name
  project      = var.project
}

resource "google_project_iam_binding" "binding" {
  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
  role    = var.roles[count.index]
  count   = length(var.roles)
  project = var.project
}

