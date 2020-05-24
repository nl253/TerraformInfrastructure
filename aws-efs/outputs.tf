output "efs" {
  value = aws_efs_file_system.efs
}

output "mount_targets" {
  value = aws_efs_mount_target.mount_target
}

output "alarm" {
  value = aws_cloudwatch_metric_alarm.fs_alarm
}
