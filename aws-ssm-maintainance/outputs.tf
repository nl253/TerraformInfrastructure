output "window" {
  value = aws_ssm_maintenance_window.window
}

output "targets_ids" {
  value = aws_ssm_maintenance_window_target.target_ids
}

output "targets_tag" {
  value = aws_ssm_maintenance_window_target.target_tag
}

output "task" {
  value = aws_ssm_maintenance_window_task.tasks
}
