provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

terraform {
  backend "s3" {
    bucket = "codebuild-nl"
    key    = "ec2/jenkins/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  tags = {
    Environment = var.env
    Application = var.app_name
  }
}

resource "aws_network_interface" "eni" {
  subnet_id = var.vpc_subnet_id
  description = "Attached to new ${var.app_name}-instance-launch-template instances"
  tags = merge({
    Name = "${var.app_name}-eni"
  }, local.tags)
  security_groups = [module.sg.security_group.id]
}

resource "aws_launch_template" "launch_template" {
  image_id                = var.ec2_image_id

  user_data               = base64encode(<<EOF
#!/bin/bash
apt update
apt install -y git nfs-{common,kernel-server} curl wget openjdk-8-jdk vim sed

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
apt update
apt install -y jenkins

JENKINS_HOME="/var/lib/jenkins"
rm -r -f "$JENKINS_HOME"
mkdir -p "$JENKINS_HOME"
mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.efs.efs.id}.efs.${var.region}.amazonaws.com:/ "$JENKINS_HOME"

cat /etc/default/jenkins | sed -E 's/^\s*JENKINS_USER=[^=]*/JENKINS_USER=root/' | sed -E 's/^\s*JENKINS_GROUP=[^=]*/JENKINS_GROUP=root/' > /tmp/jenkins-pre
cat /tmp/jenkins-pre | sed -E 's/^\s*JAVA_ARGS=.*/JAVA_ARGS="-Djava.awt.headless=true -Duser.timezone=Europe/London"/' > /tmp/jenkins

rm /etc/default/jenkins
cp /tmp/jenkins /etc/default/jenkins

systemctl restart jenkins.service

EOF
)
  key_name                = var.key_pair_name
  ebs_optimized           = true
  instance_type           = var.ec2_instance_type
  disable_api_termination = false
  tags = merge({
    Name = "${var.app_name}-instance-launch-template"
  }, local.tags)
  tag_specifications {
    resource_type = "volume"
    tags = merge({
      Name = "${var.app_name}-instance-volume"
    }, local.tags)
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge({
      scheduled-start-stop = "9 - 23"
      Name = "${var.app_name}-instance"
    }, local.tags)
  }
  name = "${var.app_name}-launch-template"
  network_interfaces {
    device_index         = 0
    network_interface_id = aws_network_interface.eni.id
  }
  block_device_mappings {
    device_name = var.ebs_device_name
    ebs {
      delete_on_termination = true
      volume_size           = var.ebs_size
      encrypted             = var.ebs_encrypted
    }
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }
  monitoring {
    enabled = true
  }
}

module "sg" {
  source   = "../aws-security-group"
  app_name = var.app_name
  vpc_id   = var.vpc_id
  env      = var.env
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
      cidr     = "0.0.0.0/0"
      protocol = "tcp"
      port     = 50000
    },
    {
      type     = "ingress"
      cidr     = "0.0.0.0/0"
      protocol = "tcp"
      port     = 8080
    },
    {
      type     = "ingress"
      cidr     = "0.0.0.0/0"
      protocol = "tcp"
      port     = 8000
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

data "aws_route53_zone" "route53_hosted_zone" {
  zone_id = var.route53_zone_id
}

module "route53_health_check" {
  source   = "../aws-route53-health-check"
  app_name = var.app_name
  env      = var.env
  ports    = [8000, 8080, 50000]
  domain   = "${var.app_name}.${substr(data.aws_route53_zone.route53_hosted_zone.name, 0, length(data.aws_route53_zone.route53_hosted_zone.name) - 1)}"
}

module "efs" {
  source            = "../aws-efs"
  app_name          = var.app_name
  encrypted         = var.efs_encrypted
  env               = var.env
  security_group_id = module.sg.security_group.id
  subnet_ids        = [var.vpc_subnet_id]
  fs_alarm_enabled  = true
}

data "aws_route53_zone" "hosted_zone" {
  zone_id = var.route53_zone_id
}

resource "aws_eip" "ip" {
  public_ipv4_pool = "amazon"
  vpc              = true
  tags = merge(local.tags, {
    Name = "${var.app_name}-instance-ip"
  })
}

resource "aws_eip_association" "ip_association" {
  allocation_id        = aws_eip.ip.id
  network_interface_id = aws_network_interface.eni.id
}

resource "aws_route53_record" "dns_records" {
  name    = var.app_name
  type    = "A"
  ttl     = "300"
  zone_id = var.route53_zone_id
  records = [aws_eip.ip.public_ip]
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
