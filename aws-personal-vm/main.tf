provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "ec2/personal-vm/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  tags = {
    "personal-vm" = "1"
    Application   = var.app_name
    Environment   = var.env
  }
}

data "aws_route53_zone" "dns_zone" {
  zone_id = var.route53_zone_id
}

data "aws_caller_identity" "id" {}

resource "aws_spot_instance_request" "vm" {
  subnet_id                       = var.subnet_id
  ami                             = var.ami
  wait_for_fulfillment            = true
  availability_zone               = "${var.region}b"
  placement_group                 = aws_placement_group.placement.placement_group_id
  cpu_core_count                  = var.cpu_core_count
  cpu_threads_per_core            = var.cpu_threads_per_core
  disable_api_termination         = false
  ebs_optimized                   = true
  monitoring                      = true
  get_password_data               = false
  hibernation                     = false
  iam_instance_profile            = aws_iam_instance_profile.profile.name
  instance_type                   = var.instance_type
  key_name                        = var.key_pair_name
  user_data                       = var.user_data
  instance_interruption_behaviour = "stop"
  tags = merge(local.tags, {
    Name = var.app_name
  })
  tenancy = "default"

  private_ip             = "10.0.183.236"
  source_dest_check      = true
  vpc_security_group_ids = [module.sg.security_group.id]

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  spot_price = "0.022500"
}

//resource "aws_volume_attachment" "volume_attachment" {
//  device_name = "/dev/sda2"
//  instance_id = aws_spot_instance_request.vm.spot_instance_id
//  volume_id   = aws_ebs_volume.volume.id
//}

resource "aws_ebs_volume" "volume" {
  iops                 = 100
  encrypted            = true
  multi_attach_enabled = false
  type                 = "gp2"
  kms_key_id           = "arn:aws:kms:${var.region}:${data.aws_caller_identity.id.account_id}:key/b8b33341-1904-4f3a-ab78-089fa8646459"
  outpost_arn          = ""
  size                 = 30
  lifecycle {
    prevent_destroy = true
  }
  availability_zone = "${var.region}b"
  tags = merge(local.tags, {
    Name                     = "${var.app_name}-volume"
    "volume-snapshot-policy" = "enabled"
  })
}

resource "aws_placement_group" "placement" {
  name     = "${var.app_name}-placement-group"
  strategy = "cluster"
  tags = merge(local.tags, {
    Name = "${var.app_name}-placement-group"
  })
}

resource "aws_eip" "ip" {
  lifecycle {
    prevent_destroy = true
  }
  public_ipv4_pool = "amazon"
  vpc              = true
  tags = merge(local.tags, {
    Name = "${var.app_name}-ip"
  })
}

resource "aws_eip_association" "ip_association" {
  instance_id   = aws_spot_instance_request.vm.spot_instance_id
  allocation_id = aws_eip.ip.id
}

resource "aws_efs_file_system" "efs" {
  lifecycle {
    prevent_destroy = true
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  provisioned_throughput_in_mibps = 0
  throughput_mode                 = "bursting"
  performance_mode                = "generalPurpose"
  tags = merge(local.tags, {
    Name = "${var.app_name}-fs"
  })
}

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_id
  security_groups = [module.sg.security_group.id]
}

resource "aws_route53_record" "dns_records" {
  name = [var.app_name, "linux"][count.index]
  type    = "A"
  ttl     = "300"
  zone_id = var.route53_zone_id
  records = [aws_eip.ip.public_ip]
  count = 2
}

module "role" {
  source   = "../aws-iam-role"
  app_name = var.app_name
  name     = "${substr(lower(replace(replace(replace(var.app_name, "-", ""), "_", ""), "/", "")), 0, 10)}instancerole"
  policies = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
  principal = {
    Service = "ec2.amazonaws.com"
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "${module.role.role.name}-profile"
  role = module.role.role.name
}

module "sg" {
  source   = "../aws-security-group"
  app_name = var.app_name
  env      = var.env
  vpc_id = var.vpc_id
  internet = true
  rules = [
    {
      type     = "ingress"
      cidr     = "0.0.0.0/0"
      protocol = "tcp"
      port     = 22
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
  self = true
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = 10
  app_name = var.app_name
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
