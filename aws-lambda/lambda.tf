provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

variable "runtime" {
  type    = string
  default = "python3.8"
}

variable "lambda_name" {
  type    = string
  default = "user_creation_lambda"
}

resource "aws_s3_bucket" "user_creation_lambda_bucket" {
  bucket        = "user-creation-lambda-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_object" "user_creation_lambda_code" {
  bucket         = aws_s3_bucket.user_creation_lambda_bucket.bucket
  key            = "index.zip"
  content_base64 = filebase64("index.zip")
}

output "user_creation_lambda_outputs_lambda_arn" {
  value = aws_lambda_function.user_creation_lambda.arn
}

output "user_creation_lambda_outputs_bucket_arn" {
  value = aws_s3_bucket.user_creation_lambda_bucket.arn
}

output "user_creation_lambda_outputs_api_arn" {
  value = aws_api_gateway_rest_api.user_creation_lambda_rest_api.id
}

resource "aws_iam_policy" "user_creation_lambda_role_policy" {
  name   = "user_creation_lambda_role_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "iam:*",
      "Resource": "*",
      "Effect": "Allow"
    }
  ]\
}
EOF
}

resource "aws_iam_policy_attachment" "user_creation_lambda_role_policy_attachment" {
  name       = "user_creation_lambda_role_policy_attachment"
  policy_arn = aws_iam_policy.user_creation_lambda_role_policy.arn
  roles      = [aws_iam_role.user_creation_lambda_role.name]
}

resource "aws_iam_role" "user_creation_lambda_role" {
  name               = "user_creation_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "user_creation_lambda_rest_api" {
  name = "user_creation_api"
  body = <<EOF
{
  "openapi": "3.0.1",
  "info": {
    "title": "Sample API",
    "description": "API description in Markdown.",
    "version": "1.0.0"
  },
  "servers": [
    {
      "url": "https://api.example.com"
    }
  ],
  "paths": {
    "/users": {
      "get": {
        "summary": "Returns a list of users.",
        "description": "Optional extended description in Markdown.",
        "responses": {
          "200": {
            "description": "OK"
          }
        }
      }
    }
  }
}
EOF
}

resource "aws_lambda_function" "user_creation_lambda" {
  function_name = var.lambda_name
  handler       = "index.handler"
  role          = aws_iam_role.user_creation_lambda_role.arn
  runtime       = var.runtime
  s3_bucket     = aws_s3_bucket.user_creation_lambda_bucket.bucket
  s3_key        = aws_s3_bucket_object.user_creation_lambda_code.key
}
