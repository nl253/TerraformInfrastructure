provider "google-beta" {}

resource "google_compute_subnetwork" "subnets" {
  name                     = "${google_compute_network.network.name}-subnet-${count.index + 1}"
  ip_cidr_range            = var.subnets[count.index].cidr
  region                   = var.subnets[count.index].region
  description              = "VPC subnet ${var.subnets[count.index].region} in ${var.subnets[count.index].region} for ${var.app_name}"
  network                  = google_compute_network.network.id
  project                  = data.google_project.project.project_id
  private_ip_google_access = true
  count                    = length(var.subnets)
  dynamic "log_config" {
    for_each = var.subnets[count.index].logging ? [1] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_network" "network" {
  description                     = "VPC for ${var.app_name}"
  name                            = var.name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  routing_mode                    = "GLOBAL"
}

resource "google_compute_network_peering" "peerings" {
  name                 = "vpc-peering-from-${substr([google_compute_network.network.name, data.google_compute_network.default_network.name][count.index], 0, 15)}-to-${substr([data.google_compute_network.default_network.name, google_compute_network.network.name][count.index], 0, 15)}"
  network              = [google_compute_network.network.id, data.google_compute_network.default_network.id][count.index]
  peer_network         = [data.google_compute_network.default_network.id, google_compute_network.network.id][count.index]
  export_custom_routes = true
  import_custom_routes = true
  count                = 2
}

resource "google_compute_subnetwork_iam_binding" "binding" {
  project    = google_compute_subnetwork.subnets[count.index].project
  region     = google_compute_subnetwork.subnets[count.index].region
  subnetwork = google_compute_subnetwork.subnets[count.index].name
  role       = "roles/compute.networkUser"
  provider   = google-beta
  members    = var.members
  condition {
    title       = "allow-traffic-between-${var.start_time_hour}-and-${var.end_time_hour}"
    description = "Allow requests between ${var.start_time_hour} and ${var.end_time_hour}"
    expression  = "request.time.getHours(\"Europe/London\") >= ${var.start_time_hour} && request.time.getHours(\"Europe/London\") <= ${var.end_time_hour}"
  }
  count = length(var.members) == 0 ? 0 : length(var.subnets)
}

resource "google_compute_firewall" "firewall" {
  name           = "${google_compute_network.network.name}-firewall"
  network        = google_compute_network.network.id
  description    = "Firewall for ${google_compute_network.network.name} VPC."
  enable_logging = true
  direction      = ["INGRESS", "EGRESS"][count.index]
  dynamic "allow" {
    for_each = ["icmp"]
    iterator = i
    content {
      protocol = i.value
    }
  }
  dynamic "allow" {
    for_each = ["udp", "tcp"]
    iterator = i
    content {
      protocol = i.value
      ports    = ["0-65535"]
    }
  }
  count = 2
}
