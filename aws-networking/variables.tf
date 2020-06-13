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
  type    = string
  default = "192.168.0.0/16"
}

variable "cidr_public" {
  type    = string
  default = "192.168.0.0/24"
}

variable "cidr_private" {
  type    = string
  default = "192.168.2.0/23"
}

variable "vpc_ids" {
  default = []
  type    = list(string)
}

variable "vpc_subnet_ids" {
  default = []
  type    = list(list(string))
}

data "aws_vpc" "vpc_default" {
  default = true
}

data "aws_subnet_ids" "vpc_default_subnet_ids" {
  vpc_id = data.aws_vpc.vpc_default.id
}
