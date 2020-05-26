provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "cloudtrail/mgmt/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_cloudtrail" "trail" {
  enable_log_file_validation    = true
  enable_logging                = true
  name                          = "management-trail"
  include_global_service_events = true
  is_multi_region_trail         = false
  is_organization_trail         = false
  s3_bucket_name                = "management-trail-nl"
  tags                          = {}
}
