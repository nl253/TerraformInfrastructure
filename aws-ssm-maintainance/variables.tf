variable "app_name" {
  type = string
}

variable "env" {
  type    = string
}

variable "cron_expr" {
  type    = string
}

variable "instance_ids" {
  type = list(string)
  default = []
}

variable "tag_name" {
  type    = string
  default = null
}

variable "task_timeout" {
  default = 100
  type    = number
}

variable "commands" {
  default = []
  type    = list(string)
}

variable "comment" {
  default = ""
  type = string
}
