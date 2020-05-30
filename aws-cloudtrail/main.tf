provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

data "aws_caller_identity" "id" {}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "cloudtrail/mgmt/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  tags                          = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_s3_bucket" "bucket" {
  lifecycle {
    prevent_destroy = true
  }
  bucket = "${var.app_name}-trail-nl"
  acl = null
  tags = local.tags
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true
    id                                     = "log-archive-rule"
    tags                                   = {}

    expiration {
      days                         = 395
      expired_object_delete_marker = false
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

  versioning {
    enabled    = false
    mfa_delete = false
  }

  policy = jsonencode({
    Statement = [
      {
        Action    = "s3:GetBucketAcl"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Resource  = "arn:aws:s3:::${var.app_name}-trail-nl"
        Sid       = "AWSCloudTrailAclCheck20150319"
      },
      {
        Action    = "s3:PutObject"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Resource  = "arn:aws:s3:::${var.app_name}-trail-nl/AWSLogs/${data.aws_caller_identity.id.account_id}/*"
        Sid       = "AWSCloudTrailWrite20150319"
      }
    ]
    Version   = "2012-10-17"
  })
}

resource "aws_cloudtrail" "trail" {
  enable_log_file_validation    = true
  enable_logging                = true
  name                          = "${var.app_name}-trail"
  include_global_service_events = true
  is_multi_region_trail         = false
  is_organization_trail         = false
  s3_bucket_name                = "${var.app_name}-trail-nl"
  tags = local.tags
}
