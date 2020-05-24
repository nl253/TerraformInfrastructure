variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "ports" {
  type = list(number)
}

variable "ports_targets" {
  type = list(number)
}

variable "region" {
  type = string
}
