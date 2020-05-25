variable "app_name" {
  default = "testapp1233491"
  type    = string
}

variable "env" {
  default = "dev"
  type    = string
}

variable "runtime" {
  default = "python37"
  type    = string
}

variable "region" {
  default = "europe-west2"
  type    = string
}

variable "memory" {
  default = 256
  type    = number
}

variable "timeout" {
  default = 30
  type    = number
}

variable "entry_point" {
  default = "hello_get"
  type    = string
}
