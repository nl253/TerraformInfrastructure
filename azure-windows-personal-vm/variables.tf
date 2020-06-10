variable "location" {
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

variable "route53_zone_id" {
  type    = string
  default = "Z0336293PW1VCW37F5HY"
}
