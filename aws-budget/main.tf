provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "billing/budget/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_caller_identity" "id" {}

variable "email" {
  type = string
  default = "norbertlogiewa96@gmail.com"
}

resource "aws_budgets_budget" "budget" {
  account_id        = data.aws_caller_identity.id.account_id
  budget_type       = "COST"
  cost_filters      = {}
  limit_amount      = "20.0"
  limit_unit        = "USD"
  name              = "Monthly AWS Budget"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2020-03-01_00:00"
  time_unit         = "MONTHLY"

  cost_types {
    include_credit             = false
    include_discount           = false
    include_other_subscription = true
    include_recurring          = true
    include_refund             = false
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_amortized              = false
    use_blended                = true
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
    subscriber_sns_topic_arns  = []
    threshold                  = 25
    threshold_type             = "PERCENTAGE"
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
    subscriber_sns_topic_arns  = []
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
    subscriber_sns_topic_arns  = []
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
  }
}
