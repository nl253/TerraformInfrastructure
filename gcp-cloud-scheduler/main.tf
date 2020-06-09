provider "google-beta" {}

data "google_project" "project" {}

variable "app_name" {
  default = "test-cron-app"
  type    = string
}

module "pubsub" {
  source    = "../gcp-pub-sub"
  invokers  = []
  endpoints = var.endpoints
  region    = var.region
  env       = var.env
  app_name  = var.app_name
}

resource "google_cloud_scheduler_job" "job" {
  name      = "${var.app_name}-cron-job"
  region    = var.region
  time_zone = var.time_zone
  schedule  = var.schedule
  pubsub_target {
    data       = base64encode("cron trigger from ${var.app_name} running in ${var.region} in project ${data.google_project.project.id} every ${var.schedule} using ${var.time_zone}")
    topic_name = module.pubsub.topic.id
  }
  retry_config {
    retry_count = 1
  }
}
