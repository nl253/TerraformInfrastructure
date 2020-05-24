provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "codebuild-nl"
    key = "jenkins/terraform.tfstate"
  }
}

resource "aws_efs_file_system" "efs" {
  lifecycle {
    prevent_destroy = true
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  performance_mode = "generalPurpose"
  encrypted = var.encrypted
  throughput_mode = "bursting"
  tags = {
    Name        = "${var.app_name}-fs"
    Application = var.app_name
    Environment = var.env
  }
}

