provider "google-beta" {}

locals {
  private_subnets = [for i in var.subnets : i if i.private == true]
  public_subnets  = [for i in var.subnets : i if i.private == false]
}

resource "google_compute_network" "networks" {
  description                     = "${["public", "private"][count.index]} VPC for ${var.app_name}"
  name                            = "${var.name}-${["public", "private"][count.index]}"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  routing_mode                    = "GLOBAL"
  count                           = 2
}

resource "google_compute_subnetwork" "subnets" {
  name                     = "${google_compute_network.networks[var.subnets[count.index].private ? 1 : 0].name}-subnet-${count.index + 1}"
  ip_cidr_range            = var.subnets[count.index].cidr
  region                   = var.subnets[count.index].region
  description              = "${google_compute_network.networks[var.subnets[count.index].private ? 1 : 0].name} VPC subnet ${var.subnets[count.index].cidr} in ${var.subnets[count.index].region} for ${var.app_name}"
  network                  = google_compute_network.networks[var.subnets[count.index].private ? 1 : 0].id
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

resource "google_compute_network_peering" "peering_default_to_public" {
  name                 = "vpc-peering-from-${substr([google_compute_network.networks[0].name, data.google_compute_network.default_network.name][count.index], 0, 15)}-to-${substr([data.google_compute_network.default_network.name, google_compute_network.networks[0].name][count.index], 0, 15)}"
  network              = [google_compute_network.networks[0].id, data.google_compute_network.default_network.id][count.index]
  peer_network         = [data.google_compute_network.default_network.id, google_compute_network.networks[0].id][count.index]
  export_custom_routes = true
  import_custom_routes = true
  count                = 2
}

resource "google_compute_network_peering" "peerings_default_to_private" {
  name                 = "vpc-peering-from-${substr([google_compute_network.networks[1].name, data.google_compute_network.default_network.name][count.index], 0, 15)}-to-${substr([data.google_compute_network.default_network.name, google_compute_network.networks[1].name][count.index], 0, 15)}"
  network              = [google_compute_network.networks[1].id, data.google_compute_network.default_network.id][count.index]
  peer_network         = [data.google_compute_network.default_network.id, google_compute_network.networks[1].id][count.index]
  export_custom_routes = true
  import_custom_routes = true
  count                = 2
}

resource "google_compute_network_peering" "peering_public_to_private" {
  name                 = "vpc-peering-from-${substr([google_compute_network.networks[1].name, google_compute_network.networks[0].name][count.index], 0, 15)}-to-${substr([google_compute_network.networks[0].name, google_compute_network.networks[1].name][count.index], 0, 15)}"
  network              = [google_compute_network.networks[1].id, google_compute_network.networks[0].id][count.index]
  peer_network         = [google_compute_network.networks[0].id, google_compute_network.networks[1].id][count.index]
  export_custom_routes = true
  import_custom_routes = true
  count                = 2
}

resource "google_compute_firewall" "firewall_private_all_from_public" {
  name           = "${google_compute_network.networks[1].name}-firewall-private-allow-from-public"
  priority       = 1000
  network        = google_compute_network.networks[1].id
  source_ranges  = [for i in local.public_subnets : i.cidr]
  description    = "Allow all TCP & UDP traffic from public subnets in ${google_compute_network.networks[0].name} to private subnets in ${google_compute_network.networks[1].name} VPC."
  enable_logging = false
  direction      = "INGRESS"
  dynamic "allow" {
    for_each = ["udp", "tcp"]
    iterator = i
    content {
      protocol = i.value
      ports    = ["0-65535"]
    }
  }
  count = length(local.private_subnets)
}

resource "google_compute_firewall" "firewall_private_block_all" {
  name           = "${google_compute_network.networks[1].name}-firewall-private-deny-all"
  priority       = 65534
  network        = google_compute_network.networks[1].id
  description    = "Catch-all deny all traffic for private subnets in ${google_compute_network.networks[1].name} VPC."
  enable_logging = true
  direction      = "INGRESS"
  dynamic "deny" {
    for_each = ["udp", "tcp"]
    iterator = i
    content {
      protocol = i.value
      ports    = ["0-65535"]
    }
  }
  dynamic "deny" {
    for_each = ["esp", "ah", "sctp", "ipip"]
    iterator = i
    content {
      protocol = i.value
    }
  }
}
