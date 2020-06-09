provider "google-beta" {}

locals {
  tags = {
    app = var.app_name
    env = var.env
  }
}

resource "google_storage_bucket" "bucket" {
  name          = var.name
  force_destroy = true
  location      = var.location
  cors {
    max_age_seconds = 60
    method          = ["GET"]
    origin          = ["*"]
    response_header = ["*"]
  }
  website {
    main_page_suffix = "index.html"
    not_found_page   = "not-found.html"
  }
  bucket_policy_only = true
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

resource "google_storage_bucket_iam_binding" "binding" {
  bucket  = google_storage_bucket.bucket.name
  members = ["allUsers"]
  role    = "roles/storage.objectViewer"
}

