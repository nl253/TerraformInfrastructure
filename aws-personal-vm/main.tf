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
    Application = var.app_name
    Environment = var.env
  }
}

data "aws_route53_zone" "dns_zone" {
  zone_id = var.route53_zone_id
}

data "aws_caller_identity" "id" {}

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

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-v", "-c"]
    command     = <<EOF
sleep 30

set -e

aws ec2 stop-instances --instance-ids ${aws_spot_instance_request.vm.spot_instance_id}

sleep 5

until [[ "$(aws --output text ec2 describe-instances --filters Name=instance-id,Values=${aws_spot_instance_request.vm.spot_instance_id} --query Reservations[0].Instances[0].State.Name)" == stopped ]]; do
 sleep 5
done

if [[ ${aws_spot_instance_request.vm.root_block_device[0].volume_id} == ${aws_ebs_volume.volume.id} ]]; then
  echo "something went wrong - old_volume_id ${aws_spot_instance_request.vm.root_block_device[0].volume_id} is the same as new"
  echo "restarting instance ${aws_spot_instance_request.vm.spot_instance_id}"
  aws ec2 start-instances --instance-ids ${aws_spot_instance_request.vm.spot_instance_id}
  exit 1
fi

aws ec2 detach-volume --instance-id ${aws_spot_instance_request.vm.spot_instance_id} --volume-id ${aws_spot_instance_request.vm.root_block_device[0].volume_id}
aws ec2 delete-volume --volume-id ${aws_spot_instance_request.vm.root_block_device[0].volume_id}
aws ec2 attach-volume --instance-id ${aws_spot_instance_request.vm.spot_instance_id} --volume-id ${aws_ebs_volume.volume.id} --device /dev/sda1

sleep 5

until [[ "$(aws --output text ec2 describe-volumes --filters Name=volume-id,Values=${aws_ebs_volume.volume.id} --query  Volumes[0].State)" == 'in-use' ]]; do
 sleep 5
done

until [[ "$(aws --output text ec2 describe-volumes --filters Name=volume-id,Values=${aws_ebs_volume.volume.id} --query  Volumes[0].Attachments[0].State)" == attached ]]; do
 sleep 5
done

sleep 120

aws ec2 start-instances --instance-ids ${aws_spot_instance_request.vm.spot_instance_id}

until [[ "$(aws --output text ec2 describe-instances --filters Name=instance-id,Values=${aws_spot_instance_request.vm.spot_instance_id} --query Reservations[0].Instances[0].State.Name)" == running ]]; do
 sleep 5
done

sleep 60

ssh -o StrictHostKeyChecking=no -i ~/.openssl/key-pair.pem ubuntu@${aws_eip.ip.public_ip} "sudo mkdir -p ${var.mount_point} && sudo apt update && sudo apt install -y git nfs-{common,kernel-server} curl wget vim sed && sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.id}.efs.${var.region}.amazonaws.com:/ ${var.mount_point}"

aws ec2 create-tags --resources ${aws_spot_instance_request.vm.spot_instance_id} --tags "Key=Application,Value=${var.app_name}" "Key=Environment,Value=${var.env}" "Key=scheduled-start-stop,Value=${var.schedule}"

EOF

  }

  spot_price = var.spot_price
}

resource "aws_ebs_volume" "volume" {
  iops                 = var.ebs_iops
  encrypted            = true
  multi_attach_enabled = false
  type                 = "gp2"
  kms_key_id           = "arn:aws:kms:${var.region}:${data.aws_caller_identity.id.account_id}:key/b8b33341-1904-4f3a-ab78-089fa8646459"
  outpost_arn          = ""
  size                 = var.ebs_volume_size
  lifecycle {
    prevent_destroy = true
  }
  availability_zone = "${var.region}b"
  tags = merge(local.tags, {
    Name                     = "${var.app_name}-volume"
    "${var.app_name}-volume-snapshot-policy" = "enabled"
  })
}

module "role_dlm" {
  source = "../aws-iam-role"
  policies = ["arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"]
  app_name = var.app_name
  env = var.env
  name = "${var.app_name}-ebs-snapshot-lifecycle-policy-dlm-role"
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
        times         = ["13:00"]
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
  vpc_id   = var.vpc_id
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
  amount   = var.budget
  app_name = var.app_name
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
