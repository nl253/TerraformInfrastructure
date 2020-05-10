variable "app_name" {
  type = string
}

variable "env" {
  type = string
  default = "dev"
}

variable "region" {
  type = string
  default = "uksouth"
}

variable "function_app_worker_runtime" {
  type = string
  default = "node"
}

variable "function_app_node_version" {
  type = string
  default = "~12"
}

variable "function_app_runtime_version" {
  type = string
  default = "~3"
}

variable "function_app_cors_origins" {
  type = list(string)
  default = ["*"]
}

variable "function_app_run_from_package" {
  type = bool
  default = true
}
