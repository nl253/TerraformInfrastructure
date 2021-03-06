resource "aws_iam_role" "role" {
  name                  = var.name
  path                  = var.path
  force_detach_policies = true
  max_session_duration  = var.sessions_duration_secs
  tags = {
    Application = var.app_name
    Environment = var.env
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = var.principal
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  count = length(var.policies) == 0 ? 1 : 0
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = var.action
        Resource = var.resource
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = length(var.policies) == 0 ? 1 : length(var.policies)
  policy_arn = length(var.policies) == 0 ? aws_iam_policy.policy[0].arn : var.policies[count.index]
  role       = aws_iam_role.role.name
}
