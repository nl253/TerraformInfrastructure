variable "app_name" {
  type    = string
  default = "jenkins"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "encrypted" {
  type = bool
  default = true
}
