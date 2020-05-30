variable "runtime" {
  type    = string
  default = "python3.8"
}

variable "name" {
  type    = string
}

variable "invoker_principal" {
  type = string
  default = null
}

variable "invoker_arn" {
  type = string
  default = null
}

variable "source_dir" {
  type = string
}

variable "policies" {
  default = []
  type = list(string)
}

variable "handler" {
  type    = string
  default = "index.handler"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type = string
}

variable "env_vars" {
  type = map(string)
  default = {}
}
