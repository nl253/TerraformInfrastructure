variable "runtime" {
  type    = string
  default = "python3.8"
}

variable "name" {
  type = string
}

variable "dead_letter_topic_name" {
  type = string
  default = "failure"
}

variable "invoker_principal" {
  type        = string
  default     = null
  description = "e.g events.amazonaws.com"
}

variable "invoker_arn" {
  type    = string
  default = null
}

variable "source_dir" {
  type = string
}

variable "policies" {
  default = []
  type    = list(string)
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
  type    = map(string)
  default = {}
}

variable "max_execution_duration" {
  default = 8
  type    = number
}

variable "max_execution_failures_per_min" {
  type    = number
  default = 5
}

variable "max_executions_per_min" {
  default = 30
  type    = number
}

variable "storage_bucket" {
  default = "codebuild-nl"
  type    = string
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "ci_bucket" {
  type    = string
  default = "codebuild-nl"
}

variable "tracing" {
  type = bool
  default = true
}

variable "vpc_id" {
  type    = string
  default = null
}
