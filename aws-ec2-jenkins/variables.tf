variable "env" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type    = string
  default = "jenkins"
}

variable "region" {
  type = string
  default = "eu-west-2"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0dc8f17938055dc89"
}

variable "vpc_subnet_id" {
  type    = string
  default = "subnet-0fca2b6f95e82b317"
}

variable "ec2_image_id" {
  type    = string
  default = "ami-006a0174c6c25ac06"
}

variable "key_pair_name" {
  type    = string
  default = "key pair"
}

variable "ec2_instance_type" {
  default = "t3.small"
  type    = string
}

variable "ebs_device_name" {
  default = "/dev/sda1"
  type    = string
}

variable "ebs_size" {
  default = 20
  type    = number
}

variable "ebs_encrypted" {
  default = false
  type    = bool
}

variable "port" {
  default = 80
  type    = number
}

variable "efs_encrypted" {
  default = true
  type    = bool
}

variable "route53_zone_id" {
  type    = string
  default = "Z0336293PW1VCW37F5HY"
}

variable "ec2_metrics" {
  default = [
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]
  type = list(string)
}
