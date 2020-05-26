variable "subnet_id" {
  type    = string
  default = "subnet-0fca2b6f95e82b317"
}

variable "region" {
  default = "eu-west-2"
}

variable "vpc_id" {
  type = string
  default = "vpc-0dc8f17938055dc89"
}

variable "app_name" {
  default = "personal-vm"
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
  type = string
  default = "ami-006a0174c6c25ac06"
}

variable "cpu_core_count" {
  type = number
  default = 1
}

variable "cpu_threads_per_core" {
  type = number
  default = 2
}

