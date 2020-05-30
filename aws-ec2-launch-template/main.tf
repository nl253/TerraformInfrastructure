provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "ec2/launch-template/example/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  tags = {
    Environment = var.env
    Application = var.app_name
  }
}

resource "aws_launch_template" "spot_fleet_fleet_launch_template" {
  vpc_security_group_ids  = [aws_security_group.instance_sg.id]
  image_id                = var.ec2_image_id
  user_data               = var.ec2_user_data
  instance_type           = var.ec2_instance_type
  disable_api_termination = false
  tags = local.tags
  tag_specifications {
    resource_type = "volume"
    tags = local.tags
  }
  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
  name = "${var.app_name}-spot-fleet-launch-template"
  /*network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.instance_sg.id]
    // subnet_id                   = var.vpc_subnet_id
  }*/
  /*instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.spot_price
    }
  }*/
  block_device_mappings {
    device_name = var.ebs_device_name
    ebs {
      volume_size = var.ebs_size
      encrypted   = var.ebs_encrypted
    }
  }
  monitoring {
    enabled = true
  }
}

resource "aws_autoscaling_group" "scaling_group" {
  availability_zones = var.AZs
  name               = "${var.app_name}-auto-scaling-group"
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  launch_template {
    id      = aws_launch_template.spot_fleet_fleet_launch_template.id
    version = "$Latest"
  }
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns = [
    aws_lb_target_group.target_group.arn
  ]
  desired_capacity = var.asg_desired_capacity
  enabled_metrics  = var.ec2_metrics
  tag {
    key                 = "Environment"
    propagate_at_launch = false
    value               = var.env
  }
  tag {
    key                 = "Application"
    propagate_at_launch = false
    value               = var.app_name
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.app_name}-target-group"
  port     = var.port
  protocol = var.alb_protocol
  vpc_id   = var.vpc_id
  tags = local.tags
}

resource "aws_security_group" "load_balancer_sg" {
  ingress {
    from_port = var.port
    protocol  = "tcp"
    to_port   = 0
  }
  egress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 0
  }
  tags = local.tags
}

resource "aws_security_group" "instance_sg" {
  ingress {
    from_port       = 0
    protocol        = "tcp"
    to_port         = 0
    security_groups = [aws_security_group.load_balancer_sg.id]
  }
  egress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 0
  }
  tags = local.tags
  lifecycle {
    create_before_destroy = true
  }
}

/*resource "aws_s3_bucket" "bucket_logs" {
  bucket = "${var.app_name}-logs"
}*/

resource "aws_lb" "load_balancer" {
  /*access_logs {
    bucket  = aws_s3_bucket.bucket_logs.bucket
    enabled = true
  }*/
  internal                   = false
  name                       = "${var.app_name}-load-balancer"
  load_balancer_type         = "application"
  subnets                    = var.vpc_subnet_ids
  security_groups            = [aws_security_group.load_balancer_sg.id]
  enable_deletion_protection = false
  ip_address_type            = "ipv4"
  tags = local.tags
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
