resource "aws_iam_user" "terraform_user" {
  name = "${var.app_name}-terraform-user"
  tags = local.tags
}

module "terraform_admin_role" {
  source = "../aws-iam-role"
  app_name = var.app_name
  name = "${var.app_name}-terraform-role"
  policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  principal = {
    AWS = "arn:aws:iam::${data.aws_caller_identity.id.account_id}:user/${aws_iam_user.terraform_user.name}"
  }
}

module "upload_role" {
  source    = "../aws-iam-role"
  app_name  = var.app_name
  name      = "${var.app_name}-upload-role"
  policies  = [aws_iam_policy.policy.arn]
  principal = {
    AWS = "arn:aws:iam::${data.aws_caller_identity.id.account_id}:user/${aws_iam_user.terraform_user.name}"
  }
}

resource "aws_iam_policy" "policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.table.name}"
        Effect   = "Allow"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${var.bucket_name}"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}
