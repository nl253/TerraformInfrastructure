provider "google-beta" {
  project = "test-project-277710"
}

terraform {
  backend "gcs" {
    bucket = "ci-nl"
    prefix = "iam/roles"
  }
}

resource "google_project_iam_custom_role" "role" {
  project     = var.project
  permissions = var.permissions
  role_id     = lower(replace(var.name, " ", "-"))
  title       = var.name
}

