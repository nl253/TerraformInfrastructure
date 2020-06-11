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
  role      = module.role.role.arn
  runtime   = var.runtime
  s3_bucket = "codebuild-nl"
  s3_key    = aws_s3_bucket_object.lambda_code.key
  environment {
    variables = merge(local.tags, var.env_vars)
  }
  vpc_config {
    security_group_ids = var.security_group_ids == null ? data.aws_security_groups.security_groups.ids : var.security_group_ids
    subnet_ids         = var.subnet_ids == null ? data.aws_subnet_ids.subnet_ids.ids : var.subnet_ids
  }
  tags = local.tags
}
