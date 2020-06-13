output "vpc" {
  value = aws_vpc.vpc
}

output "subnet_public" {
  value = aws_subnet.subnet_public
}

output "subnet_private" {
  value = aws_subnet.subnet_private
}

output "nat" {
  value = aws_nat_gateway.nat
}

output "transit_gateway" {
  value = aws_ec2_transit_gateway.transit_gateway
}

output "internet_gateway" {
  value = aws_internet_gateway.ig
}
