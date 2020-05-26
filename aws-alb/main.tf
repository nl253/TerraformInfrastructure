resource "aws_alb_target_group" "alb_target" {
  name     = "${var.app_name}-target-group-${count.index + 1}"
  port     = var.ports_targets[count.index]
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = var.ports_targets[count.index]
    healthy_threshold   = 3
    matcher             = "200-299,403"
    unhealthy_threshold = 3
    protocol            = "HTTP"
    timeout             = "15"
  }
  target_type = "ip"
  count       = length(var.ports_targets)
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = tolist(var.ports)[count.index]
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target[count.index].arn
  }
  count = length(var.ports)
}

resource "aws_alb" "alb" {
  name                       = "${var.app_name}-load-balancer"
  enable_deletion_protection = false
  load_balancer_type         = "application"
  subnets                    = tolist(var.subnet_ids)
  internal                   = false
  security_groups            = [var.security_group_id]
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_cloudwatch_metric_alarm" "health_check_alarm" {
  alarm_name          = "${var.app_name}-health-check-alarm-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "600"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Number of 5XX statuses for target group ${count.index + 1} in ${var.app_name}"
  actions_enabled     = "true"
  alarm_actions       = []
  ok_actions          = []
  dimensions = {
    TargetGroup  = aws_alb_target_group.alb_target[count.index].arn_suffix
    LoadBalancer = aws_alb.alb.arn_suffix
  }
  count = length(var.ports)
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_route53_health_check" "health_check" {
  reference_name                  = "${var.app_name}-${count.index + 1}"
  type                            = "CLOUDWATCH_METRIC"
  measure_latency                 = false
  insufficient_data_health_status = "Healthy"
  cloudwatch_alarm_region         = var.region
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.health_check_alarm[count.index].alarm_name
  count                           = length(var.ports)
  tags = {
    Name        = "Health Check ${var.app_name} ALB ${count.index + 1}"
    Application = var.app_name
    Environment = var.env
  }
}
