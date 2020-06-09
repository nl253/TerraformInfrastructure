provider "google-beta" {}

locals {
  tags = {
    app = var.app_name
    env = var.env
  }
  pubsub_account = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

module "kms" {
  source   = "../gcp-kms"
  app_name = var.app_name
  consumers = [local.pubsub_account]
  env      = var.env
}

resource "google_pubsub_topic" "topic" {
  name         = "${var.app_name}-topic"
  kms_key_name = module.kms.keys[0].self_link
  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
  labels = local.tags
}

resource "google_pubsub_subscription" "subscriptions" {
  name = "${google_pubsub_topic.topic.name}-subscription-${count.index + 1}"
  topic                = google_pubsub_topic.topic.name
  ack_deadline_seconds = var.ack_deadline_seconds
  push_config {
    push_endpoint = var.endpoints[count.index]
  }
  message_retention_duration = "${var.message_retention_seconds}s"
  retain_acked_messages      = true
  expiration_policy {
    ttl = "${var.message_expiration_seconds}s"
  }
  count  = length(var.endpoints)
  labels = local.tags
}

resource "google_pubsub_topic_iam_binding" "topic_iam_binding" {
  members = var.invokers
  role    = "roles/pubsub.publisher"
  topic   = google_pubsub_topic.topic.name
  count = length(var.invokers) == 0 ? 0 : 1
}
