provider "google" {
  project = "test-project-277710"
}

terraform {
  backend "gcs" {
    bucket = "ci-nl"
    prefix = "instance-templates/template"
  }
}

resource "google_compute_instance_template" "template" {
  machine_type   = var.machine_type
  tags           = var.tags
  can_ip_forward = false
  enable_display = false
  metadata = {
    ssh-keys = var.ssh_key
  }
  name    = var.name
  project = var.project
  region  = var.region

  disk {
    auto_delete  = true
    boot         = true
    device_name  = var.name
    disk_name    = "${var.name}-disk"
    disk_size_gb = 10
    disk_type    = var.disk_type
    interface    = ""
    labels       = {}
    mode         = "READ_WRITE"
    source       = ""
    source_image = var.image
    type         = "PERSISTENT"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = var.preemptible
  }

  network_interface {
    network            = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/default"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/${var.project}/regions/${var.region}/subnetworks/default"
    subnetwork_project = var.project

    access_config {
      network_tier = "PREMIUM"
    }
  }

  service_account {
    email = "223078289774-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
}
