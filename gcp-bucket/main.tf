provider "google-beta" {}

locals {
  tags = {
    app = var.app_name
    env = var.env
  }
}

resource "google_storage_bucket" "bucket" {
  name               = var.name
  bucket_policy_only = true
  force_destroy      = true
  location           = var.location
  versioning {
    enabled = var.versioning
  }
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      matches_storage_class = ["STANDARD"]
      age                   = var.archive_days
    }
  }
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition {
      matches_storage_class = ["NEARLINE"]
      age                   = var.archive_days * 2
    }
  }
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
    condition {
      matches_storage_class = ["COLDLINE"]
      age                   = var.archive_days * 3
    }
  }
  labels = local.tags
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

