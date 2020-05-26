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
          Action = [
            "SNS:Publish",
            "SNS:RemovePermission",
            "SNS:SetTopicAttributes",
            "SNS:DeleteTopic",
            "SNS:ListSubscriptionsByTopic",
            "SNS:GetTopicAttributes",
            "SNS:Receive",
            "SNS:AddPermission",
            "SNS:Subscribe",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceOwner" = "660847692645"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "arn:aws:sns:eu-west-2:660847692645:deployment"
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
          Action = [
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
            "SNS:Receive",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceOwner" = "660847692645"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "arn:aws:sns:eu-west-2:660847692645:account-info"
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
          Action = [
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
            "SNS:Receive",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceOwner" = "660847692645"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "arn:aws:sns:eu-west-2:660847692645:consumption-warning"
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
          Action = [
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
            "SNS:Receive",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceOwner" = "660847692645"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "arn:aws:sns:eu-west-2:660847692645:failure"
          Sid      = "__default_statement_ID"
        },
      ]
      Version = "2008-10-17"
  })
  sqs_success_feedback_sample_rate = 0
  tags                             = {}
}
