variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "tags" {
  type    = list(any)
  default = []
}

variable "ssh_key" {
  type    = string
  default = "mx:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6AtWQWiNDuf/INOewptmX7sV21HszcBgeHVLxnhy44Nvy0QJdg/C2vz25+ZeIgGMfnS0Suj/Hn4n33o8KOThhFfIFTQ89ki0Z/gHm06qpHnl/P9hOUjDz6W4DcqAzpCotr537g1YPXPipERP+8oKVesU1AQ0Jxleg7F/3QgSqYFaIl0aHwnoAd+aHcu/IkV5K/tNNCQXr++LAXrCgnttVsmkUrx30V6U3l7ABZdVeViRMjSLBNa7OBQQP6CEXXlFUmzmxDiTah8PQ5u1ZrTf3julBzTNa3+Kk43H3GWqKWkxisfdPhr6eOh/qpuloVkxtKACb3Ovw/ICv/ae4eaD1 mx@ThinkPad-13"
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "name" {
  type    = string
  default = "vm-template"
}

variable "image" {
  type    = string
  default = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2004-focal-v20200519"
}

variable "preemptible" {
  type    = bool
  default = true
}

variable "project" {
  type    = string
  default = "test-project-277710"
}

variable "disk_type" {
  type    = string
  default = "pd-standard"
}

variable "subnetwork" {
  default = "default"
  type = string
}

variable "network" {
  default = "default"
  type = string
}

variable "disk_size" {
  type = number
  default = 10
}

variable "service_account" {
  type = string
  default = "223078289774-compute@developer.gserviceaccount.com"
}

variable "service_account_scopes" {
  type = list(string)
  default = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
}
