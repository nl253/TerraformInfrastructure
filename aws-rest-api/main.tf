provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "codebuild-nl"
    key    = "apigateway/rest/example/terraform.tfstate"
  }
}

locals {
  api_name = "${var.app_name}-rest-api"
  stage = var.env
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

module "lambda" {
  source   = "../aws-lambda"
  name = "${var.app_name}-lambda-func1"
  app_name = var.app_name
  source_dir     = "${path.module}/code"
  invoker_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
  invoker_principal = "apigateway.amazonaws.com"
}

module "budget" {
  source = "../aws-budget-project"
  amount = 5
  app_name = var.app_name
}

module "rg" {
  source = "../aws-resource-group"
  app_name = var.app_name
  env = var.env
}

resource "aws_api_gateway_rest_api" "api" {
  name                     = local.api_name
  minimum_compression_size = 1
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = file("api.yaml")
  binary_media_types = var.binary_mimes
  tags = local.tags
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
//  stage_name  = local.stage
}

resource "aws_api_gateway_stage" "stage" {
  stage_name    = local.stage
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  tags = local.tags
  xray_tracing_enabled = true
  variables = local.tags
}
