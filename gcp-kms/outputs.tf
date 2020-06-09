output "keys" {
  value = google_kms_crypto_key.keys
}

output "key_ring" {
  value = google_kms_key_ring.key_ring
}
