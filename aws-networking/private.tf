resource "aws_subnet" "subnet_private" {
  cidr_block                      = var.cidr_private
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = var.az
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags = local.tags
}

resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_private.id]
  ingress {
    cidr_block = "0.0.0.0/0"
    action     = "Allow"
    from_port  = 0
    protocol   = "tcp"
    rule_no    = 101
    to_port    = 0
  }
  egress {
    cidr_block = "0.0.0.0/0"
    action     = "Allow"
    from_port  = 0
    protocol   = "tcp"
    rule_no    = 102
    to_port    = 0
  }
  tags = local.tags
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = local.tags
}

resource "aws_route_table_association" "route_table_association_private" {
  route_table_id = aws_route_table.route_table_private.id
  subnet_id      = aws_subnet.subnet_private.id
}

resource "aws_security_group" "private_sg" {
  name                   = "${var.app_name}PrivateSecurityGroup"
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = true
  ingress {
    from_port       = 0
    security_groups = [aws_security_group.public_sg.id]
    protocol        = "tcp"
    to_port         = 0
  }
  egress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 0
  }
  tags = local.tags
}
