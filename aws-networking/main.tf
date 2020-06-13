provider "aws" {
  region  = "eu-west-2"
  profile = "terraform"
  assume_role {
    role_arn = "arn:aws:iam::660847692645:role/ci-terraform-role"
  }
}

//terraform {
//  backend "s3" {
//    bucket         = "codebuild-nl"
//    key            = "vpc/example/terraform.tfstate"
//    region         = "eu-west-2"
//    profile        = "terraform"
//    encrypt        = true
//    kms_key_id     = "2b9adaa9-848d-46d2-86c9-318ede6d1e46"
//    role_arn       = "arn:aws:iam::660847692645:role/ci-upload-role"
//    dynamodb_table = "ci-terraform-state-lock-table"
//  }
//}

locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ Name = "${aws_vpc.vpc.id}-internet-gateway" }, local.tags)
}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr_vpc
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = false
  instance_tenancy                 = "default"
  enable_dns_support               = true
  tags                             = merge({ Name = "${var.app_name}-vpc" }, local.tags)
}

resource "aws_eip" "ip" {
  depends_on = [aws_internet_gateway.ig, aws_vpc.vpc]
  vpc        = true
  tags       = merge({ Name = "${aws_vpc.vpc.tags.Name}-ip" }, local.tags)
}

resource "aws_nat_gateway" "nat" {
  depends_on    = [aws_internet_gateway.ig, aws_vpc.vpc]
  subnet_id     = aws_subnet.subnet_public.id
  allocation_id = aws_eip.ip.id
  tags          = merge({ Name = "${aws_vpc.vpc.tags.Name}-nat-gateway" }, local.tags)
}

resource "aws_default_vpc_dhcp_options" "default_dhcp_options" {
  tags = merge({ Name = "${aws_vpc.vpc.tags.Name}-dhcp-options" }, local.tags)
}

module "rg" {
  source   = "../aws-resource-group"
  app_name = var.app_name
  env      = var.env
}
