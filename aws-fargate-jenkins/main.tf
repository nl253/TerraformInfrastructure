provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "codebuild-nl"
    key    = "ecs/fargate/jenkins/terraform.tfstate"
  }
}

locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}

resource "aws_cloudwatch_log_group" "logs" {
  name_prefix = "/aws/ecs/fargate/${var.app_name}/"
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = 10
  app_name = var.app_name
}

module "task_role" {
  source   = "../aws-iam-role"
  env      = var.env
  app_name = var.app_name
  name     = "${var.app_name}-task-role"
  principal = {
    Service = "ecs-tasks.amazonaws.com"
  }
  policies = ["arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"]
}

module "security_group" {
  source   = "../aws-security-group"
  app_name = var.app_name
  env      = var.env
  self     = true
  rules = [
    {
      type     = "ingress"
      protocol = "tcp"
      port     = 80
      cidr     = "0.0.0.0/0"
    },
    {
      type     = "ingress"
      protocol = "tcp"
      port     = 8080
      cidr     = "0.0.0.0/0"
    },
    {
      type     = "ingress"
      protocol = "tcp"
      port     = 50000
      cidr     = "0.0.0.0/0"
    },
    {
      type     = "ingress"
      protocol = "tcp"
      port     = 111
      cidr     = "0.0.0.0/0"
    },
    {
      type     = "ingress"
      protocol = "tcp"
      port     = 2049
      cidr     = "0.0.0.0/0"
    }
  ]
  internet = true
}

module "efs" {
  source            = "../aws-efs"
  app_name          = var.app_name
  encrypted         = var.task_efs_encrypted
  env               = var.env
  security_group_id = module.security_group.security_group.id
  subnet_ids        = [tolist(data.aws_subnet_ids.subnet_ids.ids)[0]]
  fs_alarm_enabled  = false
}

module "alb" {
  source            = "../aws-alb"
  app_name          = var.app_name
  env               = var.env
  ports             = [80, 50000]
  ports_targets     = [8080, 50000]
  region            = var.region
  security_group_id = module.security_group.security_group.id
  subnet_ids        = [tolist(data.aws_subnet_ids.subnet_ids.ids)[0], tolist(data.aws_subnet_ids.subnet_ids.ids)[1]]
  vpc_id            = var.vpc_id
}

module "route53_health_check" {
  source   = "../aws-route53-health-check"
  app_name = var.app_name
  env      = var.env
  ports    = [80, 50000]
  domain   = "${var.app_name}.${substr(data.aws_route53_zone.route53_hosted_zone.name, 0, length(data.aws_route53_zone.route53_hosted_zone.name) - 1)}"
}

resource "aws_route53_record" "dns_records" {
  name    = var.app_name
  type    = "CNAME"
  ttl     = "300"
  zone_id = var.route53_zone_id
  records = [module.alb.alb.dns_name]
}
