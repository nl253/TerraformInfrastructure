variable "env" {
  type = string
}

variable "app_name" {
  type = string
}

variable "endpoints" {
  type = list(string)
  default = []
}

variable "region" {
  type = string
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
