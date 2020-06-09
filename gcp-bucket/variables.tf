variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type    = string
  default = "europe-west2-a"
}

variable "versioning" {
  type    = bool
  default = false
}

variable "archive_days" {
  type    = number
  default = 30
}

variable "consumers_writers" {
  default = []
  type    = list(string)
}

variable "consumers_readers" {
  default = []
  type    = list(string)
}

