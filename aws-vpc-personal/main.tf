provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_network_acl" "vpc_acl" {
  lifecycle {
    prevent_destroy = true
  }
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "${var.app_name}-acl"
  }, local.tags)
}

resource "aws_route_table" "vpc_route_table" {
  lifecycle {
    prevent_destroy = true
  }
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "${var.app_name}-route-table"
  }, local.tags)
}

resource "aws_security_group_rule" "vpc_sg_rule_inbound" {
  from_port = 0
  ipv6_cidr_blocks = []
  protocol = "-1"
  prefix_list_ids = []
  security_group_id = aws_security_group.vpc_sg.id
  source_security_group_id = aws_security_group.vpc_sg.id
  to_port = 0
  type = "ingress"
}


resource "aws_security_group_rule" "vpc_sg_rule_outbound" {
  from_port = 0
  protocol = "-1"
  ipv6_cidr_blocks = []
  prefix_list_ids = []
  to_port = 0
  type = "egress"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  security_group_id = aws_security_group.vpc_sg.id
}

resource "aws_security_group" "vpc_sg" {
  lifecycle {
    prevent_destroy = true
  }
  description = "default VPC security group"
  name                   = "default"
  revoke_rules_on_delete = false
  vpc_id                 = aws_vpc.vpc.id
  tags = merge({
    Name = "${var.app_name}-sg"
  }, local.tags)
}

resource "aws_vpc_dhcp_options" "vpc_dhc_options" {
  lifecycle {
    prevent_destroy = true
  }
  domain_name = "eu-west-2.compute.internal"
  domain_name_servers = [
    "AmazonProvidedDNS",
  ]
  tags = merge({
    Name = "${var.app_name}-dhcp-options"
  }, local.tags)
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options_association" {
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhc_options.id
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc" "vpc" {
  lifecycle {
    prevent_destroy = true
  }
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = merge({
    Name = var.app_name
  }, local.tags)
}

resource "aws_internet_gateway" "vpc_ig" {
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "${var.app_name}-ig"
  }, local.tags)
}

resource "aws_route_table_association" "vpc_subnet_route_table_association" {
  route_table_id = aws_route_table.vpc_route_table.id
  subnet_id = aws_subnet.subnet_public.id
}

//resource "aws_route_table_association" "vpc_route_table_association_ig" {
//  route_table_id = aws_route_table.vpc_route_table.id
//  gateway_id = aws_internet_gateway.vpc_ig.id
//}

resource "aws_main_route_table_association" "vpc_route_table_association" {
  route_table_id = aws_route_table.vpc_route_table.id
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_public" {
  lifecycle {
    prevent_destroy = true
  }
  cidr_block = "10.0.0.0/16"
  vpc_id     = aws_vpc.vpc.id
  tags = merge({
    Name = "${var.app_name}-subnet-public"
  }, local.tags)
}
