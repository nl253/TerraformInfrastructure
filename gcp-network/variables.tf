variable "regions" {
  default = []
  type    = list(string)
}

variable "region" {
  default = "europe-west2"
  type    = string
}

variable "project" {
  type    = string
  default = "test-project-277710"
}

variable "cidrs" {
  default = ["10.0.0.0/27", "10.0.2.0/23"]
  type    = list(string)
}

variable "name" {
  default = "test-network-simple"
  type    = string
}
