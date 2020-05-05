provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidrVpc
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = false
}

resource "aws_eip" "ip" {
  depends_on = [aws_internet_gateway.ig, aws_vpc.vpc]
  vpc        = true
}

resource "aws_nat_gateway" "nat" {
  depends_on    = [aws_internet_gateway.ig, aws_vpc.vpc]
  subnet_id     = aws_subnet.subnet_public.id
  allocation_id = aws_eip.ip.id
}
