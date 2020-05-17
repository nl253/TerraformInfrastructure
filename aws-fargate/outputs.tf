output "task" {
  value = aws_ecs_task_definition.task
}

output "service" {
  value = aws_ecs_service.service
}

output "cluster" {
  value = aws_ecs_cluster.cluster
}

output "fs" {
  value = aws_efs_file_system.efs
}

output "alb" {
  value = aws_alb.alb
}

output "alarm" {
  value = aws_cloudwatch_metric_alarm.health_check_alarm
}

output "dns_record" {
  value = aws_route53_record.dns_records
}

output "health_check" {
  value = aws_route53_health_check.route53_health_check
}

output "role" {
  value = aws_iam_role.task_role
}

output "rg" {
  value = aws_resourcegroups_group.rg
}
