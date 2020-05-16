variable "app_name" {
  type    = string
  default = "testapp12345"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "task_image" {
  type    = string
  default = "jenkins/jenkins:lts"
}

variable "task_memory" {
  type    = number
  default = 2048
}

variable "task_efs_encrypted" {
  default = true
  type    = bool
}

variable "task_cpu" {
  type    = number
  default = 1024
}

variable "vpc_id" {
  type    = string
  default = "vpc-96542efe"
}

variable "subnets" {
  type    = list(string)
  default = ["subnet-93a129e9", "subnet-ef8bc786"]
}

variable "task_port_mappings" {
  type = list(map(number))
  default = [
    {
      containerPort = 50000
      hostPort      = 50000
    },
    {
      containerPort = 8080
      hostPort      = 8080
    }
  ]
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "efs_transition_to_ia" {
  type    = string
  default = "AFTER_30_DAYS"
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id
}
