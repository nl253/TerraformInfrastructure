output "role" {
  value = aws_iam_role.role
}

output "policy" {
  value = aws_iam_policy.policy
}

output "attachments" {
  value = aws_iam_role_policy_attachment.attachment
}
