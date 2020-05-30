locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = var.name
  handler       = var.handler
  tracing_config {
    mode = "Active"
  }
  role          = module.role.role.arn
  runtime       = var.runtime
  s3_bucket     = "codebuild-nl"
  s3_key        = aws_s3_bucket_object.lambda_code.key
  environment {
    variables = merge(local.tags, var.env_vars)
  }
  tags = local.tags
}
