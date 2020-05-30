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
  name                     = "${var.app_name}-rest-api"
  minimum_compression_size = 1
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = file("api.yaml")
  binary_media_types = var.binary_mimes
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
