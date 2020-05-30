data "aws_region" "region" {}

module "alarm" {
  source = "../aws-cloudwatch-alarm"
  app_name = var.app_name
  env = var.env
  metric = "5XXError"
  service = "AWS/ApiGateway"
  statistic = "Sum"
  threshold = 5
  unit = "Count"
  evaluation_periods = 1
  period_seconds = 120
  dimensions = {
    ApiName = local.api_name
  }
}

module "alarm_user_errors" {
  source = "../aws-cloudwatch-alarm"
  app_name = var.app_name
  env = var.env
  metric = "4XXError"
  service = "AWS/ApiGateway"
  statistic = "Sum"
  threshold = 10
  unit = "Count"
  evaluation_periods = 1
  period_seconds = 120
  dimensions = {
    ApiName = local.api_name
  }
}

module "health_check" {
  source = "../aws-route53-health-check"
  app_name = var.app_name
  type = "HTTPS"
  env = var.env
  path = "/${aws_api_gateway_stage.stage.stage_name}/invoke/1"
  domain = "${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.region.name}.amazonaws.com"
}

