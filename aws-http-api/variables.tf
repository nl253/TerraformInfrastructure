variable "app_name" {
  default = "test-app"
  type    = string
}

variable "env" {
  default = "dev"
  type    = string
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

variable "runtime" {
  type    = string
  default = "python3.8"
}

variable "handler" {
  type    = string
  default = "index.handler"
}

variable "payload_format_version" {
  type    = string
  default = "2.0"
}

variable "max_executions_per_min" {
  default = 100
  type    = number
}

variable "timeout_seconds" {
  type    = number
  default = 10
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id == null ? data.aws_vpc.vpc.id : var.vpc_id
}

data "aws_security_groups" "security_group_id" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id == null ? data.aws_vpc.vpc.id : var.vpc_id]
  }
}

