variable "app_name" {
  default = "ci"
  type    = string
}

variable "env" {
  default = "dev"
  type    = string
}

variable "logs_bucket_name" {
  type    = string
  default = "logs-nl"
}

variable "bucket_name" {
  type    = string
  default = "codebuild-nl"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "bucket_budget_monthly" {
  type    = number
  default = 5.0
}

variable "logs_bucket_prefix" {
  type    = string
  default = "s3/ci-bucket"
}

data "aws_caller_identity" "id" {}

data "aws_s3_bucket" "bucket_logs" {
  bucket = var.logs_bucket_name
}
