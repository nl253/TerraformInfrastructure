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
  az              = "${var.region}b"
  user            = "ubuntu"
  user_path       = "/home/ubuntu"
  ebs_device_name = "/dev/xvdb"
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_network_interface" "network_interface" {
  subnet_id         = var.subnet_id
  source_dest_check = true
  security_groups   = [module.sg.security_group.id]
  tags = merge(local.tags, {
    Name = "${var.app_name}-eni"
  })
}

resource "aws_eip" "ip" {
  network_interface = aws_network_interface.network_interface.id
  tags = merge(local.tags, {
    Name = "${var.app_name}-ip"
  })
}

resource "aws_eip_association" "ip_association" {
  allocation_id        = aws_eip.ip.id
  network_interface_id = aws_network_interface.network_interface.id
}

resource "aws_spot_instance_request" "vm" {
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.network_interface.id
  }
  ami                     = var.ami == null ? data.aws_ami.ami.image_id : var.ami
  wait_for_fulfillment    = true
  availability_zone       = local.az
  placement_group         = aws_placement_group.placement.placement_group_id
  cpu_core_count          = var.cpu_core_count
  cpu_threads_per_core    = var.cpu_threads_per_core
  disable_api_termination = false
  ebs_optimized           = true
  monitoring              = true
  get_password_data       = false
  hibernation             = false
  iam_instance_profile    = aws_iam_instance_profile.profile.name
  instance_type           = var.instance_type
  key_name                = var.key_pair_name
  user_data = base64encode(<<EOF
#!/bin/bash

set -e

# EFS ${var.efs_mount_point}
sudo mkdir -p ${var.efs_mount_point}
sudo apt update
sudo apt install -y git nfs-{common,kernel-server} curl wget {neo,}vim sed {core,find}utils python3 gawk nodejs ruby
sudo mount -t nfs \
           -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
              ${aws_efs_file_system.efs.id}.efs.${var.region}.amazonaws.com:/ ${var.efs_mount_point}

# EBS ${local.user_path}
sudo rm -r -f ${local.user_path}
sudo mkdir -p ${local.user_path}
sudo mount ${local.ebs_device_name} ${local.user_path}
sudo chown --recursive ${local.user}:${local.user} ${local.user_path}

EOF
  )
  instance_interruption_behaviour = "stop"
  tenancy                         = "default"

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
    iops                  = var.ebs_iops
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-v", "-c"]
    command = <<EOF
aws ec2 create-tags --resources ${aws_spot_instance_request.vm.spot_instance_id} \
                    --tags Key=scheduled-start-stop,Value=enabled Key=Application,Value=${var.app_name} Key=Environment,Value=${var.env} Key=Name,Value=${var.app_name}-instance
EOF
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  volume_tags = merge({
    Name = "${var.app_name}-root-volume"
  }, local.tags)

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  tags = merge({
    scheduled-start-stop = var.schedule
    Name                 = "${var.app_name}-instance"
  }, local.tags)

  spot_price = var.spot_price
}

resource "aws_volume_attachment" "volume_attachment" {
  device_name = local.ebs_device_name
  instance_id = aws_spot_instance_request.vm.spot_instance_id
  volume_id   = aws_ebs_volume.volume.id
}

resource "aws_ebs_volume" "volume" {
  lifecycle {
    prevent_destroy = true
  }
  iops                 = var.ebs_iops
  encrypted            = false
  multi_attach_enabled = false
  type                 = "gp2"
  size                 = var.ebs_volume_size
  availability_zone    = local.az
  tags = merge(local.tags, {
    Name                                     = "${var.app_name}-volume"
    "${var.app_name}-volume-snapshot-policy" = "enabled"
  })
}

module "role_dlm" {
  source   = "../aws-iam-role"
  policies = ["arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"]
  app_name = var.app_name
  env      = var.env
  name     = "${var.app_name}-ebs-snapshot-lifecycle-policy-dlm-role"
  principal = {
    Service = "dlm.amazonaws.com"
  }
}

resource "aws_dlm_lifecycle_policy" "ebs_lifecycle_policy" {
  description        = "${var.app_name}-snapshot-policy"
  execution_role_arn = module.role_dlm.role.arn
  policy_details {
    resource_types = ["VOLUME"]
    target_tags = {
      "${var.app_name}-volume-snapshot-policy" = "enabled"
    }
    schedule {
      name = "${var.app_name}-snapshot-policy-schedule"
      tags_to_add = merge(local.tags, {
        Name = "${var.app_name}-volume-snapshot"
      })
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["00:00"]
      }
      retain_rule {
        count = 14
      }
    }
  }
  tags = local.tags
}

resource "aws_placement_group" "placement" {
  name     = "${var.app_name}-placement-group"
  strategy = "cluster"
  tags = merge(local.tags, {
    Name = "${var.app_name}-placement-group"
  })
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
  name    = [var.app_name, "linux"][count.index]
  type    = "A"
  ttl     = "30"
  zone_id = var.route53_zone_id
  records = [aws_eip.ip.public_ip]
  count   = 2
}

module "role" {
  source   = "../aws-iam-role"
  app_name = var.app_name
  name     = "${substr(lower(replace(replace(replace(var.app_name, "-", ""), "_", ""), "/", "")), 0, 10)}instancerole"
  policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]
  principal = {
    Service = ["ssm.amazonaws.com", "ec2.amazonaws.com"]
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
  vpc_id   = var.vpc_id
  internet = true
  nfs      = true
  ssh      = true
  rules    = []
  self     = true
}

module "budget" {
  source   = "../aws-budget-project"
  amount   = var.budget
  app_name = var.app_name
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
