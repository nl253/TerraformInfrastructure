variable "app_name" {
  type = string
}

variable "env" {
  type    = string
  default = "dev"
}

variable "db_name" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_storage" {
  default = 20
  type    = number
}

variable "db_max_storage" {
  default = 50
  type    = number
}

variable "db_instance_type" {
  default = "db.t3.micro"
  type    = string
}

variable "db_storage_type" {
  default = "gp2"
  type    = string
}

variable "db_encrypted" {
  default = true
  type    = bool
}

variable "db_public" {
  default = true
  type    = bool
}
