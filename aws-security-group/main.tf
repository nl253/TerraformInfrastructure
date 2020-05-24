resource "aws_security_group" "security_group" {
  name = "${var.app_name}-security-group"
  revoke_rules_on_delete = true
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_security_group_rule" "rules_self" {
  self = true
  type = ["ingress", "egress"][count.index]
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.security_group.id
  count = var.self ? 2 : 0
  description = "${["ingress", "egress"][count.index]} self rule for ${aws_security_group.security_group.name}"
}

resource "aws_security_group_rule" "rules_internet" {
  type = "egress"
  from_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  to_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.security_group.id
  count = var.internet ? 1 : 0
  description = "egress internet rule for ${aws_security_group.security_group.name}"
}

resource "aws_security_group_rule" "rules" {
  cidr_blocks = [var.rules[count.index].cidr]
  from_port = var.rules[count.index].port
  protocol = var.rules[count.index].protocol
  security_group_id = aws_security_group.security_group.id
  to_port = var.rules[count.index].port
  type = var.rules[count.index].type
  count = length(var.rules)
  description = "${var.rules[count.index].type} rule for ${aws_security_group.security_group.name} port ${var.rules[count.index].port}"
}
