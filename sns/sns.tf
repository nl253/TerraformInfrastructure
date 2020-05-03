provider "aws" {
  profile = "ma"
  region = "eu-west-2"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.py"
  output_path = "index.zip"
}

data "aws_sns_topic" "account_info_topic" {
  name = "account-info"
}

data "aws_iam_role" "lambda_role" {
  name = "lambdaRole"
}

resource "aws_lambda_function" "receiver_lambda" {
  function_name = "receiver_lambda"
  handler = "index.handler"
  role = data.aws_iam_role.lambda_role.arn
  runtime = "python3.8"
  filename = "index.zip"
  source_code_hash = filebase64sha512("index.py")
  publish = true
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = "lambda_alias"
  function_name    = aws_lambda_function.receiver_lambda.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.receiver_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.account_info_topic.arn
  qualifier     = aws_lambda_alias.lambda_alias.name
}

resource "aws_sns_topic_subscription" "subscription" {
  endpoint = aws_lambda_function.receiver_lambda.arn
  protocol = "lambda"
  topic_arn = data.aws_sns_topic.account_info_topic.arn
}
