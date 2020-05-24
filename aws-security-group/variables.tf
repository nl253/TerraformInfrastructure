variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "rules" {
  type = list(map(any))
}

variable "self" {
  type = bool
}

variable "internet" {
  type = bool
}