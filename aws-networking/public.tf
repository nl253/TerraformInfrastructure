resource "aws_subnet" "subnet_public" {
  cidr_block                      = var.cidr_public
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = var.az
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false
  tags                            = merge({ Name = "${aws_vpc.vpc.tags.Name}-subnet-public" }, local.tags)
}

resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_public.id]
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
  tags = merge({ Name = "${aws_subnet.subnet_public.tags.Name}-nacl" }, local.tags)
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = merge({ Name = "${aws_subnet.subnet_public.tags.Name}-route-table" }, local.tags)
}

resource "aws_route_table_association" "route_table_association_public" {
  route_table_id = aws_route_table.route_table_public.id
  subnet_id      = aws_subnet.subnet_public.id
}

resource "aws_security_group" "public_sg" {
  name                   = "${var.app_name}PublicSecurityGroup"
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = true
  dynamic "egress" {
    iterator = protocol
    for_each = ["tcp", "udp"]
    content {
      from_port = 0
      protocol  = protocol.value
      to_port   = 0
    }
  }
  dynamic "ingress" {
    iterator = protocol
    for_each = ["tcp", "udp"]
    content {
      from_port       = 0
      prefix_list_ids = ["0.0.0.0/0"]
      protocol        = protocol.value
      to_port         = 0
    }
  }
  tags = merge({ Name = "${aws_subnet.subnet_public.tags.Name}-security-group" }, local.tags)
}
