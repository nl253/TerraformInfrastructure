variable "app_name" {
  type    = string
  default = "TestApp"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "az" {
  type    = string
  default = "eu-west-2a"
}

variable "cidr_vpc" {
  type = string
}

variable "cidr_public" {
  type = string
}

variable "cidr_private" {
  type = string
}
