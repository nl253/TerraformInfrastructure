variable "subnets" {
  type = any
  default = [
    {
      cidr    = "192.168.1.0/24"
      logging = false
      region  = "europe-west1"
    },
    {
      cidr = "192.168.0.0/24"
      region = "europe-west2"
      logging = true
    },
    {
      cidr    = "192.168.2.0/24"
      logging = false
      region  = "europe-west3"
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

variable "start_time_hour" {
  default = 9
  type    = number
}

variable "end_time_hour" {
  default = 23
  type    = number
}

variable "default_network" {
  type    = string
  default = "default"
}

variable "members" {
  default = ["user:norbertlogiewa96@gmail.com"]
  type    = list(string)
}

data "google_project" "project" {}

data "google_compute_network" "default_network" {
  name    = var.default_network
  project = data.google_project.project.project_id
}

