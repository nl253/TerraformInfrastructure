module "role" {
  source   = "../aws-iam-role"
  app_name = var.app_name
  name     = "${replace(var.app_name, "-", "")}-${replace(var.name, "-", "")}-role"
  policies = concat([
    aws_iam_policy.policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    ],
  var.policies)
  principal = {
    Service = "lambda.amazonaws.com"
  }
}

resource "aws_iam_policy" "policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "${replace(replace(replace(var.app_name, "-", ""), "_", ""), " ", "")}LambdaKMSReadOnlyPolicyStatement"
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
      },
      {
        Sid      = "${replace(replace(replace(var.app_name, "-", ""), "_", ""), " ", "")}LambdaSNSPublishToDeadLetterTopicPolicyStatement"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = data.aws_sns_topic.dead_letter_topic.arn
      }
    ]
  })
}

resource "aws_lambda_permission" "invoke_permission" {
  statement_id  = "${var.app_name}-${var.name}-invoke-permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = var.invoker_principal == null ? data.aws_caller_identity.id.account_id : var.invoker_principal
  source_arn    = var.invoker_arn
}
