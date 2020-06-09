variable "location" {
  default = "europe-west2"
  type    = string
}

locals {
  tags = {
    app = var.app_name
    env = var.env
  }
}

resource "google_kms_key_ring" "key_ring" {
  location = var.location
  name     = "${var.app_name}-key-ring"
}

resource "google_kms_crypto_key" "keys" {
  key_ring        = google_kms_key_ring.key_ring.id
  name            = "${google_kms_key_ring.key_ring.name}-key-${var.keys[count.index].name}"
  rotation_period = var.keys[count.index].rotation_period
  purpose         = var.keys[count.index].purpose
  version_template {
    algorithm        = var.keys[count.index].algorithm
    protection_level = "SOFTWARE"
  }
  labels = local.tags
  count           = length(var.keys)
}

resource "google_kms_key_ring_iam_binding" "key_ring_iam_binding" {
  members     = var.consumers
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  key_ring_id = google_kms_key_ring.key_ring.id
}
