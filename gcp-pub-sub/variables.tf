variable "env" {
  type = string
  default = "dev"
}

variable "app_name" {
  type = string
  default = "test-app-pub-sub-123"
}

variable "endpoints" {
  type = list(string)
  default = ["https://postb.in/1591679202432-3096638126298", "https://mocskss.free.beeceptor.com"]
}

variable "region" {
  type = string
  default = "europe-west2"
}

variable "invokers" {
  default = []
  type = list(string)
}

variable "ack_deadline_seconds" {
  type = number
  default = 20
}

variable "message_retention_seconds" {
  type = number
  default = 600
}

variable "message_expiration_seconds" {
  type = number
  default = 300000.5
}

data "google_project" "project" {}
