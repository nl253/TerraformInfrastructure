variable "name" {
  default = "Test Service Account"
}

variable "roles" {
  default = ["roles/compute.instanceAdmin"]
  type = list(string)
}
