output "alb" {
  value = aws_alb.alb
}

output "target_groups" {
  value = aws_alb_target_group.alb_target
}

output "listeners" {
  value = aws_lb_listener.listener
}

output "health_check" {
  value = aws_route53_health_check.health_check
}

output "metric_alarm" {
  value = aws_cloudwatch_metric_alarm.health_check_alarm
}
