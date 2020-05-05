output "vpc" {
  value = aws_vpc.vpc
}

output "subnet_public" {
  value = aws_subnet.subnet_public
}

output "subnet_private" {
  value = aws_subnet.subnet_private
}
