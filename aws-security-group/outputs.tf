output "security_group" {
  value = aws_security_group.security_group
}

output "rules" {
  value = aws_security_group_rule.rules
}

output "rules_self" {
  value = aws_security_group_rule.rules_self
}
