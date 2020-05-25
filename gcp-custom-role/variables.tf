variable "name" {
  type = string
}

variable "permissions" {
  description = "E.g. ['storage.objects.list', 'storage.buckets.list', 'storage.objects.get']"
  type        = list(string)
}

variable "project" {
  type = string
}
