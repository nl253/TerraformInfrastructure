provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "codebuild-nl"
    key    = "jenkins/terraform.tfstate"
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

module "task_role" {
  source   = "../aws-iam-role"
  action   = "Allow"
  env      = var.env
  app_name = var.app_name
  name     = "${var.app_name}-task-role"
  principal = {
    Service = "ecs-tasks.amazonaws.com"
  }
  policies = ["arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"]
}

resource "aws_security_group" "sg" {
  name = "${var.app_name}-security-group"
  egress {
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
  }
  ingress {
    from_port   = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 53
  }
  ingress {
    from_port   = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 53
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 80
  }
  ingress {
    from_port   = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 8080
  }
  ingress {
    from_port   = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 50000
  }
  ingress {
    from_port   = 111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 111
  }
  ingress {
    from_port   = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 2049
  }
  ingress {
    from_port   = 111
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 111
  }
  ingress {
    from_port   = 2049
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 2049
  }
  revoke_rules_on_delete = true
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

module "efs" {
  source            = "../aws-efs"
  app_name          = var.app_name
  encrypted         = var.task_efs_encrypted
  env               = var.env
  security_group_id = aws_security_group.sg.id
  subnet_ids        = data.aws_subnet_ids.subnet_ids.ids
  fs_alarm_enabled  = false
}

module "alb" {
  source            = "../aws-alb"
  app_name          = var.app_name
  env               = var.env
  ports             = [80, 50000]
  ports_targets     = [8080, 50000]
  region            = var.region
  security_group_id = aws_security_group.sg.id
  subnet_ids        = tolist(data.aws_subnet_ids.subnet_ids.ids)
  vpc_id            = var.vpc_id
}

module "route53_health_check_dns" {
  source   = "../aws-route53-health-check"
  app_name = var.app_name
  env      = var.env
  ports    = [80, 50000]
  uri      = "${var.app_name}.${substr(data.aws_route53_zone.route53_hosted_zone.name, 0, length(data.aws_route53_zone.route53_hosted_zone.name) - 1)}"
}

resource "aws_route53_record" "dns_records" {
  name    = var.app_name
  type    = "CNAME"
  ttl     = "300"
  zone_id = var.route53_zone_id
  records = [module.alb.alb.dns_name]
}
