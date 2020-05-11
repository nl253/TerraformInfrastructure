variable "region" {
  default = "uksouth"
  type    = string
}

variable "env" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type    = string
  default = "testapp"
}

variable "vm_size" {
  default = "Standard_F2"
  type    = string
}
