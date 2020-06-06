variable "app_name" {
  type = string
  default = "personal-vpc"
}

variable "env" {
  type = string
  default = "dev"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
