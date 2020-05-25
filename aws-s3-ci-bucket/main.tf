provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "ci-bucket/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_s3_bucket" "bucket_logs" {
  bucket = "logs-nl"
}

resource "aws_s3_bucket" "bucket" {
  lifecycle {
    prevent_destroy = true
  }
  region = "eu-west-2"
  logging {
    target_bucket = data.aws_s3_bucket.bucket_logs.bucket
    target_prefix = "s3/ci-bucket"
  }
  bucket = "codebuild-nl"
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true
    id                                     = "object-archive-rule"
    tags                                   = {}
    expiration {
      days                         = 0
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      days = 395
    }
    noncurrent_version_transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }
  }
  versioning {
    enabled    = true
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
