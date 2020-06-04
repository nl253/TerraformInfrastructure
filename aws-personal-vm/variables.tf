variable "subnet_id" {
  type    = string
  default = "subnet-0fca2b6f95e82b317"
}

variable "region" {
  default = "eu-west-2"
  type    = string
}

variable "vpc_id" {
  type    = string
  default = "vpc-0dc8f17938055dc89"
}

variable "mount_point" {
  type = string
  default = "/data"
}

variable "app_name" {
  default = "personal-vm"
  type    = string
}

variable "route53_zone_id" {
  type    = string
  default = "Z0336293PW1VCW37F5HY"
}

variable "env" {
  default = "dev"
  type    = string
}

variable "user_data" {
  type    = string
  default = ""
}

variable "key_pair_name" {
  type    = string
  default = "key pair"
}

variable "instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "ami" {
  type    = string
  default = "ami-006a0174c6c25ac06"
}

variable "cpu_core_count" {
  type    = number
  default = 1
}

variable "cpu_threads_per_core" {
  type    = number
  default = 2
}

variable "efs_mount_point" {
  type = string
  default = "/data"
}

variable "private_ip" {
  type = string
  default = "10.0.183.236"
}

variable "spot_price" {
  type = string
  default = "0.0178"
}

variable "ebs_volume_size" {
  type = number
  default = 30
}

variable "ebs_iops" {
  type = number
  default = 100
}

variable "budget" {
  type = number
  default = 10
}

variable "schedule" {
  default = "18 - 22"
  type = string
}
