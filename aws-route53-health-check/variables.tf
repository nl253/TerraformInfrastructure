variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "domain" {
  type = string
}

variable "ports" {
  type = list(number)
  default = [443]
}

variable "path" {
  type    = string
  default = "/"
}

variable "max_failures" {
  type    = number
  default = 5
}

variable "request_interval" {
  type    = number
  default = 30
}

variable "type" {
  type    = string
  default = "HTTP"
}
