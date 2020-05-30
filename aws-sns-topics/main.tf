provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "sns/topics/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_caller_identity" "id" {}

resource "aws_sns_topic" "topics" {
  lifecycle {
    prevent_destroy = true
  }
  application_success_feedback_sample_rate = 0
  display_name                             = replace(var.topics[count.index], "-", " ")
  http_success_feedback_sample_rate        = 0
  kms_master_key_id                        = null
  lambda_success_feedback_sample_rate      = 0
  name                                     = replace(var.topics[count.index], " ", "-")
  count                                    = length(var.topics)
  policy = jsonencode(
    {
      Id = "SNSServicePolicyFor${replace(upper(var.topics[count.index]), " ", "")}"
      Statement = [
        {
          Action = var.action
          Condition = {
            StringEquals = {
              "AWS:SourceOwner" = data.aws_caller_identity.id.account_id
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = data.aws_caller_identity.id.account_id
          }
          Resource = "arn:aws:sns:${var.region}:${data.aws_caller_identity.id.account_id}:${replace(var.topics[count.index], " ", "-")}"
          Sid      = "__default_statement_ID"
        }
      ]
      Version = "2008-10-17"
    }
  )
  sqs_success_feedback_sample_rate = 0
  tags                             = {
    Application = var.app_name
    Environment = var.env
  }
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = 5
  app_name = var.app_name
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
