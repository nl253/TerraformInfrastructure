output "ec2_template" {
  value = aws_launch_template.launch_template
}

output "security_group" {
  value = module.sg
}

output "budget" {
  value = module.budget.budget
}

output "resource_group" {
  value = module.rg.rg
}

output "network_interface" {
  value = aws_network_interface.eni
}

output "ip" {
  value = aws_eip.ip
}

output "association" {
  value = aws_eip_association.ip_association
}

output "dns_record" {
  value = aws_route53_record.dns_records
}
