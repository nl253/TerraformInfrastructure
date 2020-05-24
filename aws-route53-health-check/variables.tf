variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "uri" {
  type = string
}

variable "ports" {
  type = list(number)
}
