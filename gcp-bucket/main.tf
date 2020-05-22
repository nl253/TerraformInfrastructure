provider "google" {
  project = "test-project-277710"
}

terraform {
  backend "gcs" {
    bucket = "ci-nl"
    prefix = "gcs/bucket/ci-nl"
  }
}

resource "google_storage_bucket" "bucket" {
  name          = var.name
  force_destroy = true
  location      = var.location
  versioning {
    enabled = var.versioning
  }
}
