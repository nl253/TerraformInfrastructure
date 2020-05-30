module "alarm_failures" {
  source = "../aws-cloudwatch-alarm"
  metric = "Errors"
  service = "AWS/Lambda"
  statistic = "Sum"
  threshold = var.max_execution_failures_per_min * 2
  unit = "Count"
  evaluation_periods = 1
  period_seconds = 120
  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }
  app_name = var.app_name
  env = var.env
}

module "alarm_duration" {
  source = "../aws-cloudwatch-alarm"
  metric = "Duration"
  service = "AWS/Lambda"
  statistic = "Average"
  threshold = var.max_execution_duration
  unit = "Seconds"
  app_name = var.app_name
  evaluation_periods = 1
  period_seconds = 120
  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }
  env = var.env
}

module "alarm_overload" {
  source = "../aws-cloudwatch-alarm"
  metric = "Invocations"
  service = "AWS/Lambda"
  statistic = "Sum"
  threshold = var.max_executions_per_min * 2
  unit = "Count"
  app_name = var.app_name
  evaluation_periods = 1
  period_seconds = 120
  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }
  env = var.env
}
