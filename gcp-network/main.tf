provider "google-beta" {
  project = "test-project-277710"
}

terraform {
  backend "gcs" {
    bucket = "ci-nl"
    prefix = "networks/basic"
  }
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.name}-subnet-${count.index + 1}"
  ip_cidr_range            = var.cidrs[count.index]
  region                   = length(var.regions) == 0 ? var.region : var.regions[count.index]
  network                  = google_compute_network.network.id
  project                  = var.project
  private_ip_google_access = true
  count                    = length(var.cidrs)
}

resource "google_compute_network" "network" {
  name                    = var.name
  auto_create_subnetworks = false
}
