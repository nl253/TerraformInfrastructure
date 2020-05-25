resource "aws_efs_file_system" "efs" {
  lifecycle {
    prevent_destroy = true
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  performance_mode = "generalPurpose"
  encrypted        = var.encrypted
  throughput_mode  = "bursting"
  tags = {
    Name        = "${var.app_name}-fs"
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_efs_mount_target" "mount_target" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = tolist(var.subnet_ids)[count.index]
  security_groups = [var.security_group_id]
  count           = length(tolist(var.subnet_ids))
}

resource "aws_cloudwatch_metric_alarm" "fs_alarm" {
  count               = var.fs_alarm_enabled ? 1 : 0
  alarm_name          = "${var.app_name}-fs-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  statistic           = "Average"
  period              = 600
  threshold           = 1000
  metric_name         = "BurstCreditBalance"
  namespace           = "AWS/EFS"
  dimensions = {
    FileSystemId = aws_efs_file_system.efs.id
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
