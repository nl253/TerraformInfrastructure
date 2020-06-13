resource "aws_ec2_transit_gateway" "transit_gateway" {
  description                     = "Transit gateway between VPCs for ${var.app_name}."
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags                            = merge({ Name = "${var.app_name}-transit-gateway" }, local.tags)
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_vpc_attachment" {
  subnet_ids                                      = concat([data.aws_subnet_ids.vpc_default_subnet_ids.ids, [aws_subnet.subnet_public.id, aws_subnet.subnet_private.id]], var.vpc_subnet_ids)[count.index]
  dns_support                                     = "enable"
  vpc_id                                          = concat([data.aws_vpc.vpc_default.id, aws_vpc.vpc.id], [var.vpc_ids])[count.index]
  ipv6_support                                    = "disable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  transit_gateway_id                              = aws_ec2_transit_gateway.transit_gateway.id
  tags                                            = merge({ Name = "${aws_ec2_transit_gateway.transit_gateway.tags.Name}-${concat([data.aws_vpc.vpc_default.id, aws_vpc.vpc.id], [var.vpc_ids])[count.index]}-attachment" }, local.tags)
  count                                           = 2 + length(var.vpc_ids)
}
