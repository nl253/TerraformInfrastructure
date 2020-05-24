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
  value = module.efs.efs
}

output "alb" {
  value = module.alb
}

output "dns_record" {
  value = aws_route53_record.dns_records
}

output "health_check_dns" {
  value = module.route53_health_check_dns.health_check
}

output "role" {
  value = module.task_role
}
