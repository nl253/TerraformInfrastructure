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
  health_check_route_path  = "/health-check"
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
    allow_methods = [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "PATCH",
    ]
    allow_credentials = false
    allow_headers = [
      "Accept",
      "Accept-Encoding",
      "Accept-Language",
      "Accept-Charset",
      "Cookie",
      "DNT",
    ]
    allow_origins = ["*"]
    expose_headers = [
      "Content-Type",
      "Content-Encoding",
      "Content-Language",
      "Content-Length",
      "Set-Cookie",
      "Date",
      "Age",
      "Content-Disposition",
    ]
  }
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "log_group" {
  name_prefix       = aws_apigatewayv2_api.api.name
  tags              = local.tags
  retention_in_days = 7
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id          = aws_apigatewayv2_api.api.id
  stage_variables = local.tags
  name            = "${aws_apigatewayv2_api.api.name}-stage-${var.env}"
  auto_deploy     = true
  tags            = local.tags
  default_route_settings {
    throttling_burst_limit   = 1000
    throttling_rate_limit    = 100
    detailed_metrics_enabled = true
  }
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format = jsonencode({
      sourceIp          = "$context.identity.sourceIp"
      userAgent         = "$context.identity.userAgent"
      integrationStatus = "$context.integrationStatus"
      latency           = "$context.responseLatency"
      stage             = "$context.stage"
      method            = "$context.httpMethod"
      path              = "$context.path"
      status            = "$context.status"
      requestId         = "$context.extendedRequestId"
      error             = "$context.error.message"
    })
  }
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
