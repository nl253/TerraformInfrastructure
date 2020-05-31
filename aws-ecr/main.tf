provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "ecr/nl253/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  tags = {
    Environment = var.env
    Application = var.app_name
  }
}

resource "aws_ecr_repository" "repo" {
  lifecycle {
    prevent_destroy = false
  }
  name = "${var.app_name}-repo"
  tags = local.tags
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.repo.name
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid = "${upper(replace(replace(var.app_name, "-", ""), "_", ""))}ECRPolicy"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  })
}


