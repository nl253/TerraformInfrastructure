resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name                = "${var.app_name}-alarm"
  alarm_description         = "${var.metric} in  ${var.app_name} (${var.env}) has exceeded ${var.threshold}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 3
  insufficient_data_actions = []
  ok_actions                = []
  threshold                 = tostring(var.threshold)
  treat_missing_data        = "notBreaching"
  statistic                 = var.statistic
  alarm_actions             = []
  unit                      = var.unit
  metric_name               = var.metric
  period                    = var.period
  namespace                 = var.service
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
