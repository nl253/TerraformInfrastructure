provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

resource "aws_iam_policy_attachment" "example_policy_attachment" {
  name = "example_policy_attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  roles = [aws_iam_role.example_role.name]
}

resource "aws_iam_role" "example_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet_public" {
  vpc_id = aws_vpc.example_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-2c"
}

resource "aws_security_group" "example_security_group" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_security_group_rule" "example_security_group_rule_inbound" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.example_security_group.id
  to_port = 8080
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "example_security_group_rule_outbound" {
  from_port = 0
  protocol = "tcp"
  security_group_id = aws_security_group.example_security_group.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port = 0
  type = "egress"
}

resource "aws_instance" "example" {
  ami                         = "ami-0c216d3ab383cc403"
  associate_public_ip_address = false
  user_data                   = "find -type f >> ~/files.txt"
  instance_type               = "t2.nano"
  vpc_security_group_ids      = [aws_security_group.example_security_group.id]
  subnet_id                   = aws_subnet.example_subnet_public.id
  monitoring                  = true
  count                       = 2
}
