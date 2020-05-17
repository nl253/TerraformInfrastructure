variable "app_name" {
  type    = string
  default = "jenkins"
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

variable "route53_zone_id" {
  type    = string
  default = "Z0336293PW1VCW37F5HY"
}

variable "fs_alarm_enabled" {
  type    = bool
  default = false
}
