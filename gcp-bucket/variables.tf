variable "name" {
  type = string
}

variable "location" {
  type    = string
  default = "EUROPE-WEST2"
}

variable "versioning" {
  type    = bool
  default = false
}
