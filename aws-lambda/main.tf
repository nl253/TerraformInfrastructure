data "aws_s3_bucket" "ci_bucket" {
  bucket = "codebuild-nl"
}

data "archive_file" "zip" {
  output_path = "index.zip"
  type = "zip"
  source_dir = var.source_dir
}

data "aws_caller_identity" "id" {}

resource "aws_s3_bucket_object" "lambda_code" {
  bucket              = data.aws_s3_bucket.ci_bucket.bucket
  key                 = "${var.app_name}/index.zip"
  content_base64      = filebase64(data.archive_file.zip.output_path)
  content_disposition = "attachment"
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_iam_policy" "policy_kms" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "${replace(replace(replace(var.app_name, "-", ""), "_", ""), " ", "")}LambdaKMSReadOnlyPolicyStatement"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GetKeyPolicy",
          "kms:Verify",
          "kms:ListKeys",
          "kms:GetKeyRotationStatus",
          "kms:ListAliases",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

module "role" {
  source = "../aws-iam-role"
  app_name = var.app_name
  name = "${var.app_name}-lambda-role"
  policies = concat([
    aws_iam_policy.policy_kms.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
  ],
  var.policies)
  principal = {
    Service = "lambda.amazonaws.com"
  }
}

resource "aws_lambda_permission" "invoke_permission" {
  statement_id = "${var.app_name}-${var.name}-invoke-permission"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal = var.invoker_principal == null ? data.aws_caller_identity.id.account_id : var.invoker_principal
  source_arn = var.invoker_arn
}

resource "aws_lambda_function" "lambda" {
  function_name = var.name
  handler       = var.handler
  tracing_config {
    mode = "Active"
  }
  role          = module.role.role.arn
  runtime       = var.runtime
  s3_bucket     = data.aws_s3_bucket.ci_bucket.bucket
  s3_key        = aws_s3_bucket_object.lambda_code.key
  environment {
    variables = merge({
      Application = var.app_name
      Environment = var.env
    }, var.env_vars)
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
