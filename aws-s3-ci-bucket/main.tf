provider "aws" {
  region  = "eu-west-2"
  profile = "terraform"
  assume_role {
    role_arn = "arn:aws:iam::660847692645:role/ci-terraform-role"
  }
}

terraform {
  backend "s3" {
    bucket         = "codebuild-nl"
    key            = "s3/bucket/ci/terraform.tfstate"
    region         = "eu-west-2"
    profile        = "terraform"
    encrypt        = true
    kms_key_id     = "2b9adaa9-848d-46d2-86c9-318ede6d1e46"
    role_arn       = "arn:aws:iam::660847692645:role/ci-upload-role"
    dynamodb_table = "ci-terraform-state-lock-table"
  }
}

locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_kms_alias" "kms_key_alias" {
  target_key_id = aws_kms_key.kms_key.id
  name          = "alias/${var.app_name}-terraform-state-kms-key"
}

resource "aws_kms_key" "kms_key" {
  lifecycle {
    prevent_destroy = true
  }
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  is_enabled               = true
  tags                     = local.tags
}

resource "aws_s3_bucket" "bucket" {
  lifecycle {
    prevent_destroy = true
  }
  bucket = var.bucket_name
  region = var.region
  logging {
    target_bucket = data.aws_s3_bucket.bucket_logs.bucket
    target_prefix = var.logs_bucket_prefix
  }
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true
    id                                     = "object-archive-rule"
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
  tags = local.tags
}

resource "aws_dynamodb_table" "table" {
  lifecycle {
    prevent_destroy = true
  }
  name         = "${var.app_name}-terraform-state-lock-table"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  server_side_encryption {
    enabled = false
  }
  tags = local.tags
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = var.bucket_budget_monthly
  app_name = var.app_name
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
