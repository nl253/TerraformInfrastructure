variable "appName" {
  type    = string
  default = "TestApp"
}

variable "az" {
  type    = string
  default = "eu-west-2a"
}

variable "cidrVpc" {
  type = string
}

variable "cidrPublic" {
  type = string
}

variable "cidrPrivate" {
  type = string
}
