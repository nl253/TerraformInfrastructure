variable "name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "logging_bucket" {
  type = string
  default = "logs-nl"
}

variable "env" {
  default = "dev"
  type    = string
}

