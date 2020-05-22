provider "google" {
  project = "test-project-277710"
}

terraform {
  backend "gcs" {
    bucket = "ci-nl"
    prefix = "cloud-functions/example"
  }
}

module "bucket" {
  source = "../gcp-bucket"
  name   = "${var.app_name}-store"
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "main.py"
  output_path = "main.zip"
}

resource "google_storage_bucket_object" "code" {
  name         = "${var.app_name}-${var.env}-func-code.zip"
  content_type = "text/plain"
  source       = "main.zip"
  bucket       = module.bucket.bucket.name
}

resource "google_cloudfunctions_function" "func" {
  name                  = "${var.app_name}-func"
  entry_point           = var.entry_point
  runtime               = var.runtime
  region                = var.region
  available_memory_mb   = var.memory
  trigger_http          = true
  source_archive_bucket = module.bucket.bucket.name
  source_archive_object = google_storage_bucket_object.code.name
  timeout               = var.timeout
  labels = {
    application = var.app_name
    environment = var.env
  }
}

