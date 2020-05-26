variable "app_name" {
  type    = string
  default = "testapp123"
}

variable "threshold" {
  type    = number
  default = 10
}

variable "period" {
  type    = number
  default = 120
}

variable "unit" {
  type    = string
  default = null
}

variable "statistic" {
  type    = string
  default = "Average"
}

variable "metric" {
  default = "BucketSizeBytes"
  type    = string
}

variable "service" {
  default = "AWS/S3"
  type    = string
}

variable "env" {
  default = "dev"
  type    = string
}
