variable "app_name" {
  type    = string
  default = "scheduled-start-stop-association"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "tag_name" {
  default = "scheduled-start-stop"
  type    = string
}

variable "tag_value" {
  type    = string
  default = "enabled"
}

variable "hour_start" {
  type    = number
  default = 9
}

variable "hour_end" {
  type    = number
  default = 22
}
