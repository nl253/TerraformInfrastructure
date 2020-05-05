provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

resource "aws_iam_role" "role" {
  name                  = var.name
  path                  = var.path
  force_detach_policies = true
  max_session_duration  = var.sessionDurationSecs
  tags = {
    APP = var.appName
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = var.principal
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = var.action,
        Resource = var.resource,
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.role.name
}
