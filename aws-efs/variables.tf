variable "app_name" {
  type    = string
}

variable "env" {
  type    = string
}

variable "encrypted" {
  type = bool
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "fs_alarm_enabled" {
  type = bool
}
