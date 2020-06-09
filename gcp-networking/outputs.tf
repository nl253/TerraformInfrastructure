output "network" {
  value = google_compute_network.network
}

output "subnets" {
  value = google_compute_subnetwork.subnets
}

output "firewall" {
  value = google_compute_firewall.firewall
}

output "peerings" {
  value = google_compute_network_peering.peerings
}
