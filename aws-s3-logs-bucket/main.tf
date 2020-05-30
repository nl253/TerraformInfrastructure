provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "logs-bucket/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_caller_identity" "id" {}

resource "aws_s3_bucket" "bucket" {
  lifecycle {
    prevent_destroy = true
  }
  region = "eu-west-2"
  bucket = "logs-nl"
  grant {
    permissions = [
      "FULL_CONTROL",
    ]
    type = "Group"
    uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
  }
  grant {
    permissions = [
      "READ_ACP",
      "WRITE",
    ]
    type = "Group"
    uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true
    id                                     = "log-rule-archive"
    tags                                   = {}
    expiration {
      days                         = 365
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      days = 395
    }
    noncurrent_version_transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }
    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }
  }
  policy = jsonencode(
    {
      Id = "Policy1589018326365"
      Statement = [
        {
          Action = "s3:*"
          Effect = "Allow"
          Principal = {
            AWS = data.aws_caller_identity.id.account_id
          }
          Resource = "arn:aws:s3:::logs-nl/*"
          Sid      = "Stmt1589018323777"
        }
      ]
      Version = "2012-10-17"
    }
  )
  versioning {
    enabled    = false
    mfa_delete = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = 5
  app_name = var.app_name
}
