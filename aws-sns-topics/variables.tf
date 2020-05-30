variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "topics" {
  type    = list(string)
  default = ["deployment", "account info", "failure", "consumption warning"]
}

variable "action" {
  type = any
  default = [
    "SNS:AddPermission",
    "SNS:DeleteTopic",
    "SNS:GetTopicAttributes",
    "SNS:ListSubscriptionsByTopic",
    "SNS:Publish",
    "SNS:Receive",
    "SNS:RemovePermission",
    "SNS:SetTopicAttributes",
    "SNS:Subscribe",
  ]
}

variable "app_name" {
  default = "sns-topics"
  type    = string
}

variable "env" {
  default = "dev"
  type    = string
}
