provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

data "aws_instance" "instances" {
  instance_tags = {
    "${var.tag_name}" = var.tag_value
  }
}

module "role" {
  source   = "../aws-iam-role"
  app_name = var.app_name
  name     = "${var.app_name}-ssm-association-role"
  resource = "*"
  action = [
    "ec2:StartInstances",
    "ec2:StopInstances",
    "ec2:DescribeInstanceStatus"
  ]
  principal = {
    Service = "ssm.amazonaws.com"
  }
}

resource "aws_ssm_association" "associations" {
  name                             = ["AWS-StartEC2Instance", "AWS-StopEC2Instance"][count.index]
  association_name                 = "${var.app_name}-${["start", "stop"][count.index]}-association"
  automation_target_parameter_name = "InstanceId"
  count                            = 2
  schedule_expression              = "cron(0 00 ${[var.hour_start, var.hour_end][count.index]} ? * * *)"
  parameters = {
    AutomationAssumeRole = module.role.role.arn
    InstanceId           = data.aws_instance.instances.id
  }
  targets {
    key    = "tag-key"
    values = [var.tag_name]
  }
}
