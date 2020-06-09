variable "schedule" {
  type = string
}

variable "time_zone" {
  type    = string
  default = "Etc/UTC"
}

variable "env" {
  type = string
}

variable "region" {
  default = "europe-west1"
  type    = string
}

variable "endpoints" {
  type = list(string)
}
