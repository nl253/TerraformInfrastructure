variable "action" {
  type        = any
  description = "Actions that the principal will do."
}

variable "resource" {
  type        = any
  description = "Resources that the principal can perform actions on."
}

variable "principal" {
  type        = any
  description = "The one that will use the role."
}

variable "name" {
  type        = string
  description = "The name of this new role."
}

variable "path" {
  type        = string
  description = "The path to group the new role under."
  default     = "/"
}

variable "sessions_duration_secs" {
  type        = number
  description = "How many seconds sessions should last for."
  default     = 3600
}

variable "app_name" {
  type = string
}