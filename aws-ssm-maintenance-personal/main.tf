provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "ssm/personal/terraform.tfstate"
    region = "eu-west-2"
  }
}

variable "app_name" {
  default = "ssm"
  type    = string
}

variable "env" {
  type    = string
  default = "dev"
}

module "maintenance" {
  source   = "../aws-ssm-maintenance"
  app_name = var.app_name
  env      = var.env
  commands = ["find -type f"]
  instance_ids = [
    "mi-018e8423e1e16af4d",
    "mi-06f4f0b85a98ddf8d",
    "mi-0c89869c046368d48",
  ]
  cron_expr = "cron(0 0 0 ? * * *)"
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = 5
  app_name = var.app_name
}
