provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "example-cloudwatch-alarm/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name                = "${var.app_name}-alarm"
  alarm_description         = "${var.metric} in  ${var.app_name} (${var.env}) has exceeded ${var.threshold}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 3
  insufficient_data_actions = []
  ok_actions                = []
  threshold                 = tostring(var.threshold)
  treat_missing_data        = "notBreaching"
  statistic                 = var.stat
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

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
