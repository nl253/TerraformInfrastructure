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

variable "action" {
  type = any
  default = [
    "SNS:AddPermission",
    "SNS:DeleteTopic",
    "SNS:GetTopicAttributes",
    "SNS:ListSubscriptionsByTopic",
    "SNS:Publish",
    "SNS:Receive",
    "SNS:RemovePermission",
    "SNS:SetTopicAttributes",
    "SNS:Subscribe",
  ]
}

data "aws_caller_identity" "id" {}

variable "region" {
  type    = string
  default = "eu-west-2"
}

resource "aws_sns_topic" "topic_deployment" {
  application_success_feedback_sample_rate = 0
  display_name                             = "Deployment"
  http_success_feedback_sample_rate        = 0
  kms_master_key_id                        = "alias/aws/sns"
  lambda_success_feedback_sample_rate      = 0
  name                                     = "deployment"
  policy = jsonencode(
    {
      Id = "__default_policy_ID"
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
            AWS = "*"
          }
          Resource = "arn:aws:sns:${var.region}:${data.aws_caller_identity.id.account_id}:deployment"
          Sid      = "__default_statement_ID"
        },
      ]
      Version = "2008-10-17"
    }
  )
  sqs_success_feedback_sample_rate = 0
  tags                             = {}

}

resource "aws_sns_topic" "topic_account_info" {
  application_success_feedback_sample_rate = 0
  display_name                             = "Account Information"
  http_success_feedback_sample_rate        = 0
  kms_master_key_id                        = "alias/aws/sns"
  lambda_success_feedback_sample_rate      = 0
  name                                     = "account-info"
  policy = jsonencode(
    {
      Id = "__default_policy_ID"
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
            AWS = "*"
          }
          Resource = "arn:aws:sns:${var.region}:${data.aws_caller_identity.id.account_id}:account-info"
          Sid      = "__default_statement_ID"
        },
      ]
      Version = "2008-10-17"
    }
  )
  sqs_success_feedback_sample_rate = 0
  tags                             = {}
}

resource "aws_sns_topic" "topic_consumption_warning" {
  application_success_feedback_sample_rate = 0
  display_name                             = "Consumption Warning"
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  name                                     = "consumption-warning"
  policy = jsonencode(
    {
      Id = "__default_policy_ID"
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
            AWS = "*"
          }
          Resource = "arn:aws:sns:${var.region}:${data.aws_caller_identity.id.account_id}:consumption-warning"
          Sid      = "__default_statement_ID"
        },
      ]
      Version = "2008-10-17"
    }
  )
  sqs_success_feedback_sample_rate = 0
  tags                             = {}
}

resource "aws_sns_topic" "topic_failure" {
  application_success_feedback_sample_rate = 0
  display_name                             = "Failure"
  http_success_feedback_sample_rate        = 0
  kms_master_key_id                        = "alias/aws/sns"
  lambda_success_feedback_sample_rate      = 0
  name                                     = "failure"
  policy = jsonencode(
    {
      Id = "__default_policy_ID"
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
            AWS = "*"
          }
          Resource = "arn:aws:sns:${var.region}:${data.aws_caller_identity.id.account_id}:failure"
          Sid      = "__default_statement_ID"
        },
      ]
      Version = "2008-10-17"
  })
  sqs_success_feedback_sample_rate = 0
  tags                             = {}
}
