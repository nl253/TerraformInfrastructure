resource "aws_ssm_maintenance_window" "window" {
  cutoff   = 1
  duration = 3
  name     = "${var.app_name}-maintainanace-window"
  schedule = var.cron_expr
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_ssm_maintenance_window_target" "target_ids" {
  resource_type = "INSTANCE"
  name          = "${aws_ssm_maintenance_window.window.name}-target-ids"
  description   = "Target of ${aws_ssm_maintenance_window.window.name}."
  window_id     = aws_ssm_maintenance_window.window.id
  targets {
    key    = "InstanceIds"
    values = var.instance_ids
  }
  count = length(var.instance_ids) == 0 ? 0 : 1
}

resource "aws_ssm_maintenance_window_target" "target_tag" {
  window_id     = aws_ssm_maintenance_window.window.id
  name          = "${aws_ssm_maintenance_window.window.name}-target-tags"
  description   = "Target of ${aws_ssm_maintenance_window.window.name}."
  resource_type = "INSTANCE"
  count         = var.tag_name == null ? 0 : 1
  targets {
    key    = "tag-key"
    values = [var.tag_name]
  }
}

data "aws_iam_role" "service_role" {
  name = "SSMServiceRole"
}

resource "aws_ssm_maintenance_window_task" "tasks" {
  max_concurrency  = "2"
  max_errors       = "1"
  name             = "${aws_ssm_maintenance_window.window.name}-target-run-shell-script-command"
  description      = "Shell script command for targets in ${aws_ssm_maintenance_window.window.name}."
  service_role_arn = data.aws_iam_role.service_role.arn
  priority         = 1
  task_arn         = "AWS-RunShellScript"
  task_type        = "RUN_COMMAND"
  task_invocation_parameters {
    run_command_parameters {
      comment         = var.comment
      timeout_seconds = var.task_timeout
      parameter {
        name   = "executionTimeout"
        values = ["${var.task_timeout}"]
      }
      parameter {
        name   = "commands"
        values = var.commands
      }
    }
  }
  window_id = aws_ssm_maintenance_window.window.id
  targets {
    key    = var.tag_name == null ? "InstanceIds" : "WindowTargetIds"
    values = [length(var.instance_ids) == 0 ? aws_ssm_maintenance_window_target.target_tag[0].id : aws_ssm_maintenance_window_target.target_ids[0].id]
  }
}
