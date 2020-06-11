resource "aws_apigatewayv2_route" "route_health_check" {
  api_id         = aws_apigatewayv2_api.api.id
  route_key      = "GET ${local.health_check_route_path}"
  operation_name = trim(replace(replace(replace(replace(local.health_check_route_path, "/", " "), "-", " "), "_", " "), "  ", " "), " ")
  target         = "integrations/${aws_apigatewayv2_integration.lambda_health_check_integration.id}"
}

module "lambda_health_check" {
  source                 = "../aws-lambda"
  app_name               = var.app_name
  invoker_principal      = "apigateway.amazonaws.com"
  runtime                = var.runtime
  handler                = var.handler
  max_executions_per_min = var.max_executions_per_min
  max_execution_duration = var.timeout_seconds
  invoker_arn            = "${aws_apigatewayv2_api.api.execution_arn}/${aws_apigatewayv2_stage.stage.name}/*${local.health_check_route_path}"
  name                   = local.lambda_health_check_name
  vpc_id                 = local.vpc_id
  subnet_ids             = local.subnet_ids
  security_group_ids     = local.security_group_ids
  source_dir             = "${path.module}/code${local.health_check_route_path}"
}

resource "aws_apigatewayv2_integration" "lambda_health_check_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = module.lambda_health_check.lambda.invoke_arn
  payload_format_version = var.payload_format_version
  passthrough_behavior   = "WHEN_NO_MATCH"
  timeout_milliseconds   = 1000 * var.timeout_seconds
}
