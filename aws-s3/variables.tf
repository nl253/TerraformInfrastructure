variable "bucket_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "logging_bucket" {
  type = string
}

variable "env" {
  default = "dev"
  type = string
}

