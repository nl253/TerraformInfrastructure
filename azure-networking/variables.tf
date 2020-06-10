variable "location" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "app_name" {
  type = string
}

variable "public_subnet" {
  type    = string
  default = "10.0.0.0/24"
}

variable "private_subnet" {
  type    = string
  default = "10.0.1.0/24"
}

variable "address_space" {
  default = ["10.0.0.0/16"]
  type    = list(string)
}

variable "env" {
  type = string
}

variable "public_subnet_network_security_rules" {
  default = [
    {
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      destination_address_prefix = "*"
    }
  ]
  type = list(map(any))
}
