resource "aws_budgets_budget" "project_budget" {
  name              = "${var.app_name}-budget-monthly"
  budget_type       = "COST"
  limit_amount      = "${var.amount}"
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    TagKeyValue = "user:Application${"$"}${var.app_name}"
  }

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
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
    subscriber_sns_topic_arns  = []
    threshold                  = 85
    threshold_type             = "PERCENTAGE"
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
    subscriber_sns_topic_arns  = []
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
  }
}
