variable "name" {
  default = "terraform"
}

variable "roles" {
  default = [
    "roles/editor",
    "roles/storage.admin",
    "roles/iam.securityAdmin",
    "roles/storage.objectAdmin",
  ]
  type = list(string)
}

variable "project" {
  default = "test-project-277710"
}
