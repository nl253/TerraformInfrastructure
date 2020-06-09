provider "google-beta" {
  project = "test-project-277710"
}

terraform {
  backend "gcs" {
    bucket = "ci-nl"
    prefix = "gcs/bucket/ci-nl"
  }
}

variable "consumers_writers" {
  default = []
  type    = list(string)
}

variable "consumers_readers" {
  default = []
  type    = list(string)
}

resource "google_storage_bucket_iam_binding" "binding_readers" {
  bucket  = google_storage_bucket.bucket.name
  members = var.consumers_readers
  role    = "roles/storage.objectViewer"
  count   = length(var.consumers_readers) == 0 ? 0 : 1
}

resource "google_storage_bucket_iam_binding" "binding_writers" {
  bucket  = google_storage_bucket.bucket.name
  members = var.consumers_writers
  role    = "roles/storage.admin"
  count   = length(var.consumers_writers) == 0 ? 0 : 1
}

resource "google_storage_bucket" "bucket" {
  name               = var.name
  bucket_policy_only = true
  force_destroy      = true
  location           = var.location
  versioning {
    enabled = var.versioning
  }
}
