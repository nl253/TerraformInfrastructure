locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = var.name
  handler       = var.handler
  role          = module.role.role.arn
  runtime       = var.runtime
  s3_bucket     = var.ci_bucket
  s3_key        = aws_s3_bucket_object.lambda_code.key
  publish       = true
  tracing_config {
    mode = var.tracing ? "Active" : "PassThrough"
  }
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_topic_name == null ? [] : [1]
    content {
      target_arn = data.aws_sns_topic.dead_letter_topic.arn
    }
  }
  environment {
    variables = merge(local.tags, var.env_vars)
  }
  vpc_config {
    security_group_ids = var.security_group_ids == null ? data.aws_security_groups.security_groups.ids : var.security_group_ids
    subnet_ids         = var.subnet_ids == null ? data.aws_subnet_ids.subnet_ids.ids : var.subnet_ids
  }
  tags = merge({ Name = var.name }, local.tags)
}

resource "aws_s3_bucket_object" "lambda_code" {
  bucket              = var.storage_bucket
  key                 = "lambda/${var.app_name}/${var.name}/code/index.zip"
  content_base64      = filebase64(data.archive_file.zip.output_path)
  content_disposition = "attachment"
  tags                = local.tags
}
