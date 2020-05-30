data "aws_region" "region" {}

data "aws_caller_identity" "id" {}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name                = "${var.app_name}-${replace(var.service, "AWS/", "")}-${var.unit}-${var.metric}-alarm"
  alarm_description         = "${var.statistic} of ${var.metric} in ${var.app_name} (${var.env}) has exceeded ${var.threshold} ${var.evaluation_periods}x"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = var.evaluation_periods
  insufficient_data_actions = []
  ok_actions                = []
  threshold                 = tostring(var.threshold)
  treat_missing_data        = "ignore"
  statistic                 = var.statistic
  alarm_actions             = var.sns_arns
  actions_enabled           = true
  unit                      = var.unit
  metric_name               = var.metric
  period                    = var.period_seconds
  namespace                 = var.service
  dimensions                = var.dimensions
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
