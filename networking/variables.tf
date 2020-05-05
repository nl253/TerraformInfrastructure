variable "appName" {
  type    = string
  default = "TestApp"
}

variable "az" {
  type    = string
  default = "eu-west-2a"
}

variable "cidrVpc" {
  type    = string
  default = "192.168.0.0/16"
}

variable "cidrPublic" {
  type    = string
  default = "192.168.0.0/24"
}

variable "cidrPrivate" {
  type    = string
  default = "192.168.1.0/24"
}
