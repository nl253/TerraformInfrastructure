data "aws_ami" "ami" {
  owners      = ["aws-marketplace", "amazon"]
  most_recent = true

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }

  filter {
    name   = "hypervisor"
    values = ["xen"]
  }

  filter {
    name   = "is-public"
    values = ["true"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  name_regex = "ubuntu-minimal/images/hvm-ssd/ubuntu-focal-[-_0-9a-z.]+-amd64-minimal-[0-9]+"
}

data "aws_route53_zone" "dns_zone" {
  zone_id = var.route53_zone_id
}

data "aws_caller_identity" "id" {}
