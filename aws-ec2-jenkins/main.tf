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

data "aws_caller_identity" "id" {}

resource "aws_network_interface" "eni" {
  subnet_id   = var.vpc_subnet_id
  description = "Attached to new ${var.app_name}-instance-launch-template instances"
  tags = merge({
    Name = "${var.app_name}-eni"
  }, local.tags)
  security_groups = [module.sg.security_group.id]
}

resource "aws_iam_instance_profile" "profile" {
  name = "${module.role.role.name}-profile"
  role = module.role.role.name
}

resource "aws_iam_policy" "ssm_session_policy" {
  name = "${var.app_name}-ssm-session-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:SendCommand"
        ]
        Resource = [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.id.account_id}:document/SSM-SessionManagerRunShell"
        ]
        Condition = {
          BoolIfExists = {
            "ssm:SessionDocumentAccessCheck" = "true"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeInstanceProperties",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:TerminateSession"
        ]
        Resource = [
          "arn:aws:ssm:*:*:session/ma-*",
          "arn:aws:ssm:*:*:session/mx-*",
          "arn:aws:ssm:*:*:session/md-*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_session_admin_policy" {
  name = "${var.app_name}-ssm-session-admin-policy"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ssm:StartSession",
            "ssm:SendCommand"
          ]
          Resource = [
            "arn:aws:ec2:*:*:instance/*"
          ]
          Condition = {
            "StringLike" : {
              "ssm:resourceTag/Name" : [
                "${var.app_name}-instance"
              ]
            }
          }
        },
        {
          Effect = "Allow",
          Action = [
            "ssm:DescribeSessions",
            "ssm:GetConnectionStatus",
            "ssm:DescribeInstanceInformation",
            "ssm:DescribeInstanceProperties",
            "ec2:DescribeInstances"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ssm:CreateDocument",
            "ssm:UpdateDocument",
            "ssm:GetDocument"
          ]
          Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.id.account_id}:document/SSM-SessionManagerRunShell"
        },
        {
          Effect = "Allow"
          Action = [
            "ssm:TerminateSession"
          ]
          Resource = [
            "arn:aws:ssm:*:*:session/ma-*",
            "arn:aws:ssm:*:*:session/mx-*",
            "arn:aws:ssm:*:*:session/md-*"
          ]
        }
      ]
  })
}

module "role" {
  source   = "../aws-iam-role"
  app_name = var.app_name
  name     = "${substr(lower(replace(replace(replace(var.app_name, "-", ""), "_", ""), "/", "")), 0, 10)}instancerole"
  policies = [
    aws_iam_policy.ssm_session_admin_policy.arn,
    aws_iam_policy.ssm_session_policy.arn,
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]
  principal = {
    Service = ["ssm.amazonaws.com", "ec2.amazonaws.com"]
  }
}

resource "aws_launch_template" "launch_template" {
  image_id = var.ec2_image_id

  user_data = base64encode(<<EOF
#!/bin/bash

chmod a+w /tmp

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

echo "mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.efs.efs.id}.efs.${var.region}.amazonaws.com:/ \"$JENKINS_HOME\"" >> /etc/profile.d/jenkins-efs-mount.sh

cat /etc/default/jenkins | sed -E 's/^\s*JENKINS_USER=[^=]*/JENKINS_USER=root/' | sed -E 's/^\s*JENKINS_GROUP=[^=]*/JENKINS_GROUP=root/' > /tmp/jenkins-pre
cat /tmp/jenkins-pre | sed -E 's/^\s*JAVA_ARGS=.*/JAVA_ARGS="-Djava.awt.headless=true -Duser.timezone=Europe\/London"/' > /tmp/jenkins

rm /etc/default/jenkins
cp /tmp/jenkins /etc/default/jenkins

systemctl restart jenkins.service

EOF
  )
  provisioner "local-exec" {
    interpreter = ["bash", "-v", "-c"]
    command     = <<EOF
id=$(aws --output text ec2 describe-instances --filters Name=tag:Name,Values=${var.app_name}-instance Name=instance-state-name,Values=running --query Reservations[0].Instances[0].InstanceId)

if [[ $id == None ]]; then
  id=$(aws --output text ec2 describe-instances --filters Name=tag:Name,Values=${var.app_name}-instance Name=instance-state-name,Values=stopped --query Reservations[0].Instances[0].InstanceId)
fi

if [[ ! $id == None ]]; then
  aws ec2 terminate-instances --instance-ids $id
  sleep 10
  status=$(aws ec2 --output text describe-instances --filters Name=instance-id,Values=i-0ac080c6fe6fdc985 --query Reservations[0].Instances[0].State.Name)
  until [[ $status == terminated ]]; do
    sleep 5
  done
  aws ec2 run-instances --launch-template '{ "LaunchTemplateName": "jenkins-launch-template", "Version": "$Latest" }'
fi
EOF
  }
  key_name      = var.key_pair_name
  ebs_optimized = true
  instance_type = var.ec2_instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }
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
      scheduled-start-stop = "enabled"
      Name                 = "${var.app_name}-instance"
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
  ssh      = true
  nfs      = true
  rules = [
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
