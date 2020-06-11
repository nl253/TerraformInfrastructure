provider "aws" {
  region  = "eu-west-2"
  profile = "terraform"
  assume_role {
    role_arn = "arn:aws:iam::660847692645:role/ci-terraform-role"
  }
}

terraform {
  backend "s3" {
    bucket         = "codebuild-nl"
    key            = "apigatewayv2/http-api/example/terraform.tfstate"
    region         = "eu-west-2"
    profile        = "terraform"
    encrypt        = true
    kms_key_id     = "2b9adaa9-848d-46d2-86c9-318ede6d1e46"
    role_arn       = "arn:aws:iam::660847692645:role/ci-upload-role"
    dynamodb_table = "ci-terraform-state-lock-table"
  }
}

locals {
  lambda_health_check_name = "${var.app_name}-health-check-lambda"
  vpc_id                   = var.vpc_id == null ? data.aws_vpc.vpc.id : var.vpc_id
  subnet_ids               = var.subnet_ids == null ? data.aws_subnet_ids.subnet_ids.ids : var.subnet_ids
  security_group_ids       = var.security_group_ids == null ? data.aws_security_groups.security_group_id.ids : var.security_group_ids
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "${var.app_name}-http-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = false
    allow_headers     = []
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    allow_origins     = ["*"]
    expose_headers    = []
  }
  tags = local.tags
}

//resource "aws_apigatewayv2_vpc_link" "api_vpc_link" {
//  name               = "${aws_apigatewayv2_api.api.name} HTTP API VPC link"
//  security_group_ids = local.security_group_ids
//  subnet_ids         = local.subnet_ids
//  tags               = local.tags
//}

resource "aws_apigatewayv2_integration" "lambda_health_check_integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_alias.lambda_health_check_alias.invoke_arn
  //  connection_type        = "VPC_LINK"
  //  connection_id          = aws_apigatewayv2_vpc_link.api_vpc_link.id
  payload_format_version = "2.0"
  passthrough_behavior   = "WHEN_NO_MATCH"
  timeout_milliseconds   = 29000
}

resource "aws_cloudwatch_log_group" "log_group" {
  name_prefix       = aws_apigatewayv2_api.api.name
  tags              = local.tags
  retention_in_days = 7
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "${aws_apigatewayv2_api.api.name}-stage-${var.env}"
  auto_deploy = true
  tags        = local.tags
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format          = "{\"sourceIp\": \"$context.identity.sourceIp\", \"userAgent\": \"$context.identity.userAgent\", \"integrationStatus\": \"$context.integrationStatus	\", \"latency\": \"$context.responseLatency\", \"stage\": \"$context.stage\", \"method\": \"$context.httpMethod\", \"path\": \"$context.path\", \"status\": \"$context.status\", \"requestId\" \"$context.extendedRequestId\",	\"$context.error.message\"}"
  }
}

module "lambda_health_check" {
  source             = "../aws-lambda"
  app_name           = var.app_name
  name               = local.lambda_health_check_name
  vpc_id             = local.vpc_id
  subnet_ids         = local.subnet_ids
  security_group_ids = local.security_group_ids
  source_dir         = "${path.module}/code"
}

resource "aws_apigatewayv2_route" "route_health_check" {
  api_id         = aws_apigatewayv2_api.api.id
  route_key      = "GET /heath-check"
  operation_name = "Health Check"
  target         = "integrations/${aws_apigatewayv2_integration.lambda_health_check_integration.id}"
}

resource "aws_lambda_alias" "lambda_health_check_alias" {
  function_name    = module.lambda_health_check.lambda.function_name
  function_version = module.lambda_health_check.lambda.version
  name             = "${local.lambda_health_check_name}-${var.env}"
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = 3
  app_name = var.app_name
}
