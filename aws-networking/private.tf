resource "aws_subnet" "subnet_private" {
  cidr_block                      = var.cidr_private
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = var.az
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge({ Name = "${aws_vpc.vpc.tags.Name}-subnet-private-default" }, local.tags)
}

resource "aws_default_network_acl" "private_nacl" {
  subnet_ids             = [aws_subnet.subnet_private.id]
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    iterator = protocol
    content {
      cidr_block = aws_vpc.vpc.cidr_block
      action     = "Allow"
      from_port  = 0
      protocol   = protocol.value
      rule_no    = 107
      to_port    = 0
    }
  }
  dynamic "ingress" {
    for_each = var.vpc_ids
    iterator = vpc_id
    content {
      cidr_block = vpc_id.value
      action     = "Allow"
      from_port  = 0
      protocol   = vpc_id.value
      rule_no    = 109
      to_port    = 0
    }
  }
  dynamic "egress" {
    for_each = ["tcp", "udp"]
    iterator = protocol
    content {
      cidr_block = "0.0.0.0/0"
      action     = "Allow"
      from_port  = 0
      protocol   = protocol.value
      rule_no    = 200
      to_port    = 0
    }
  }
  tags = merge({ Name = "${aws_subnet.subnet_private.tags.Name}-security-group" }, local.tags)
}

resource "aws_default_route_table" "route_table_private" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge({ Name = "${aws_subnet.subnet_private.tags.Name}-route-table" }, local.tags)
}

resource "aws_default_security_group" "private_sg" {
  lifecycle {
    prevent_destroy = true
  }
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = true
  dynamic "ingress" {
    iterator = i
    for_each = ["tcp", "udp"]
    content {
      from_port       = 0
      security_groups = [aws_security_group.public_sg.id]
      protocol        = i.value
      to_port         = 0
    }
  }
  dynamic "ingress" {
    iterator = i
    for_each = ["tcp", "udp"]
    content {
      from_port = 0
      self      = true
      protocol  = i.value
      to_port   = 0
    }
  }
  dynamic "ingress" {
    iterator = protocol
    for_each = ["tcp", "udp"]
    content {
      from_port       = 0
      prefix_list_ids = [aws_subnet.subnet_public.cidr_block]
      protocol        = protocol.value
      to_port         = 0
    }
  }
  dynamic "egress" {
    iterator = protocol
    for_each = ["tcp", "udp"]
    content {
      from_port = 0
      protocol  = protocol.value
      to_port   = 0
    }
  }
  tags = merge({ Name = "${aws_subnet.subnet_private.tags.Name}-security-group" }, local.tags)
}

