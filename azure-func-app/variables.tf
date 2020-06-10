variable "app_name" {
  type = string
}

variable "env" {
  type    = string
}

variable "region" {
  type    = string
}

variable "function_app_worker_runtime" {
  type    = string
}

variable "function_app_node_version" {
  type    = string
}

variable "function_app_runtime_version" {
  type    = string
  default = "~3"
}

variable "function_app_cors_origins" {
  type    = list(string)
  default = ["*"]
}

variable "code_zip_uri" {
  type = string
}

variable "function_app_https_only" {
  type    = bool
  default = true
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_replication" {
  type    = string
  default = "LRS"
}

variable "app_service_plan_tier" {
  type    = string
  default = "Dynamic"
}

variable "app_service_plan_size" {
  type    = string
  default = "Y1"
}
