provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

variable "bucket_name" {
  default = "my-special-bucket-for-storing-stuff"
  type    = string
}

data "aws_caller_identity" "id" {}
data "aws_s3_bucket" "logging_bucket" {
  bucket = "logs-nl"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true
  logging {
    target_bucket = data.aws_s3_bucket.logging_bucket.bucket
    target_prefix = var.bucket_name
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  cors_rule {
    allowed_methods = ["POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["Content-Type", "Content-Length", "Encoding", "Content-Encoding", "Transfer-Encoding"]
    allowed_headers = ["Accept"]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "",
    Statement = [
      {
        Sid       = "AllowAccessTo${title(aws_s3_bucket.bucket.bucket)}FromMyAccount"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.id.account_id}:user/ma" }
        Action    = "s3:*"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
      }
    ]
  })
}
