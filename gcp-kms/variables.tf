variable "app_name" {
  type    = string
}

variable "env" {
  type = string
}

variable "keys" {
  type = list(map(string))
  default = [
    {
      name = "key"
      rotation_period = "86400s"
      purpose = "ENCRYPT_DECRYPT"
      algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
    }
  ]
}

variable "consumers" {
  default = []
  type = list(string)
}
