provider "aws" {
  region = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key = "ci-bucket"
    region = "eu-west-2"
  }
}

resource "aws_s3_bucket" "bucket" {
  lifecycle {
    prevent_destroy = true
  }
  bucket = "codebuild-nl"
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled = true
    id = "object-archive-rule"
    tags = {}
    expiration {
      days = 0
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      days = 395
    }
    noncurrent_version_transition {
      days = 30
      storage_class = "ONEZONE_IA"
    }
  }
  versioning {
    enabled = false
    mfa_delete = false
  }

  /*server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aes256"
      }
    }
  }*/
}
