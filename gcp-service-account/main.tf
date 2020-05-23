provider "google" {
  project = "test-project-277710"
}

terraform {
  backend "gcs" {
    bucket = "ci-nl"
    prefix = "service-accounts/service-account"
  }
}

resource "google_service_account" "service_account" {
  account_id   =  replace(lower(var.name), " ", "-")
  display_name = var.name
}

data "google_iam_policy" "policy" {
  binding {
    members = [
      "serviceAccount:${google_service_account.service_account.email}"
    ]
    role = var.roles[count.index]
  }
  audit_config {
    service = "allServices"
    audit_log_configs {
      log_type = "DATA_WRITE"
    }
    audit_log_configs {
      log_type = "ADMIN_READ"
    }
  }
  count = length(var.roles)
}

