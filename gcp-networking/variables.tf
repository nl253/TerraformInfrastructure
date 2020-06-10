variable "subnets" {
  type = any
  default = [
    {
      cidr    = "192.168.1.0/24"
      region  = "europe-west1"
      logging = false
      private = false
    },
    {
      cidr    = "192.168.2.0/24"
      region  = "europe-west2"
      logging = true
      private = true
    }
  ]
}

variable "name" {
  type    = string
  default = "test-net"
}

variable "app_name" {
  default = "test-vpc-app-1234"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "default_network" {
  type    = string
  default = "default"
}

data "google_project" "project" {}

data "google_compute_network" "default_network" {
  name    = var.default_network
  project = data.google_project.project.project_id
}
