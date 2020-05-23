variable "name" {
  default = "TestRole"
}

variable "permissions" {
  default = ["storage.objects.list", "storage.buckets.list", "storage.objects.get"]
  type    = list(string)
}

variable "project" {
  default = "test-project-277710"
}

