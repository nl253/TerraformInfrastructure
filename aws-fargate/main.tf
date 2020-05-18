provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "codebuild-nl"
    key = "jenkins/terraform.tfstate"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name               = "${var.app_name}-cluster"
  capacity_providers = ["FARGATE"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_efs_mount_target" "mount_target" {
  file_system_id  = data.aws_efs_file_system.efs.id
  subnet_id       = tolist(data.aws_subnet_ids.subnet_ids.ids)[count.index]
  security_groups = [aws_security_group.sg.id]
  count           = length(tolist(data.aws_subnet_ids.subnet_ids.ids))
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_security_group" "sg" {
  name = "${var.app_name}-security-group"
  egress {
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
  }
  ingress {
    from_port   = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 53
  }
  ingress {
    from_port   = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 53
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 80
  }
  ingress {
    from_port   = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 8080
  }
  ingress {
    from_port   = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 50000
  }
  ingress {
    from_port   = 111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 111
  }
  ingress {
    from_port   = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 2049
  }
  ingress {
    from_port   = 111
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 111
  }
  ingress {
    from_port   = 2049
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 2049
  }
  revoke_rules_on_delete = true
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name_prefix = "/aws/ecs/fargate/${var.app_name}/"
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
  role       = aws_iam_role.task_role.name
}

resource "aws_iam_role" "task_role" {
  name                  = "${var.app_name}-task-role"
  path                  = "/"
  force_detach_policies = true
  tags = {
    Application = var.app_name
    Environment = var.env
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "task" {
  depends_on = [aws_security_group.sg]
  container_definitions = jsonencode([
    {
      name         = "${var.app_name}-app"
      image        = var.task_image
      cpu          = var.task_cpu
      memory       = var.task_memory
      essential    = true
      portMappings = var.task_port_mappings
      user         = "0"
      mountPoints = [{
        containerPath = "/var/jenkins_home"
        sourceVolume  = "${var.app_name}-storage"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-group         = aws_cloudwatch_log_group.logs.name
          awslogs-stream-prefix = aws_cloudwatch_log_group.logs.name_prefix
        }
      }
    }
  ])
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.task_memory
  cpu                      = var.task_cpu
  family                   = "${var.app_name}-task"

  volume {
    name = "${var.app_name}-storage"
    efs_volume_configuration {
      file_system_id = data.aws_efs_file_system.efs.id
      root_directory = "/"
    }
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
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
    FileSystemId = data.aws_efs_file_system.efs.id
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

module "rg" {
  source = "../aws-resource-group"
  app_name = var.app_name
  env = var.env
}

resource "aws_ecs_service" "service" {
  depends_on                        = [aws_security_group.sg, aws_alb.alb, aws_alb_target_group.alb_target, aws_lb_listener.listener]
  name                              = "${var.app_name}-service"
  task_definition                   = aws_ecs_task_definition.task.arn
  cluster                           = aws_ecs_cluster.cluster.id
  platform_version                  = "1.4.0"
  desired_count                     = length(tolist(data.aws_subnet_ids.subnet_ids.ids))
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 120
  network_configuration {
    subnets          = tolist(data.aws_subnet_ids.subnet_ids.ids)
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = true
  }
  load_balancer {
    container_name   = "${var.app_name}-app"
    container_port   = 8080
    target_group_arn = aws_alb_target_group.alb_target[0].arn
  }
  load_balancer {
    container_name   = "${var.app_name}-app"
    container_port   = 50000
    target_group_arn = aws_alb_target_group.alb_target[1].arn
  }
}

resource "aws_alb_target_group" "alb_target" {
  name     = "${var.app_name}-target-group-${count.index}"
  port     = [8080, 50000][count.index]
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
    port                = "${[8080, 50000][count.index]}"
    healthy_threshold   = 3
    matcher             = "200-299,403"
    unhealthy_threshold = 3
    protocol            = "HTTP"
    timeout             = "15"
  }
  target_type = "ip"
  count       = 2
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = [80, 50000][count.index]
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target[count.index].arn
  }
  count = 2
}

resource "aws_alb" "alb" {
  name                       = "${var.app_name}-load-balancer"
  enable_deletion_protection = false
  load_balancer_type         = "application"
  subnets                    = tolist(data.aws_subnet_ids.subnet_ids.ids)
  internal                   = false
  security_groups            = [aws_security_group.sg.id]
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_cloudwatch_metric_alarm" "health_check_alarm" {
  alarm_name          = "${var.app_name}-health-check-alarm-${count.index}"
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
  count = 2
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_route53_health_check" "route53_health_check" {
  reference_name                  = "${var.app_name}-${count.index}"
  type                            = "CLOUDWATCH_METRIC"
  measure_latency                 = false
  insufficient_data_health_status = "Healthy"
  cloudwatch_alarm_region         = var.region
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.health_check_alarm[count.index].alarm_name
  count                           = 2
  tags = {
    Name        = "Health Check ${var.app_name} ALB ${count.index + 1}"
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_route53_health_check" "route53_health_check-dns" {
  port              = [80, 50000][count.index]
  fqdn              = "${var.app_name}.${substr(data.aws_route53_zone.route53_hosted_zone.name, 0, length(data.aws_route53_zone.route53_hosted_zone.name) - 1)}"
  type              = "HTTP"
  reference_name    = "${var.app_name}-dns"
  measure_latency   = true
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"
  count             = 2
  tags = {
    Name        = "Health Check ${var.app_name} ${count.index + 1}"
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_route53_record" "dns_records" {
  name    = var.app_name
  type    = "CNAME"
  ttl     = "300"
  zone_id = var.route53_zone_id
  records = [aws_alb.alb.dns_name]
}
