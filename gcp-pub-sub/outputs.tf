output "topic" {
  value = google_pubsub_topic.topic
}

output "subscriptions" {
  value = google_pubsub_subscription.subscriptions
}
