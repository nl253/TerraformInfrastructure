provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
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

resource "aws_efs_file_system" "efs" {
  lifecycle {
    prevent_destroy = false
  }
  encrypted = var.task_efs_encrypted
  lifecycle_policy {
    transition_to_ia = var.efs_transition_to_ia
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_efs_mount_target" "mount_target" {
  file_system_id  = aws_efs_file_system.efs.id
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
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
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
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
    }
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_ecs_service" "service" {
  depends_on                        = [aws_security_group.sg, aws_alb.alb, aws_alb_target_group.alb_target, aws_lb_listener.listener]
  name                              = "${var.app_name}-service"
  task_definition                   = aws_ecs_task_definition.task.arn
  cluster                           = aws_ecs_cluster.cluster.id
  platform_version                  = "1.4.0"
  desired_count                     = length(tolist(data.aws_subnet_ids.subnet_ids.ids))
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 300
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
  port     = count.index == 0 ? 8080 : 50000
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
    port                = "8080"
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
  port              = count.index == 0 ? 8080 : 50000
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



resource "aws_route53_health_check" "route53_health_check" {
  reference_name                  = "${var.app_name}-${count.index}"
  fqdn                            = "${var.app_name}.${data.aws_route53_zone.route53_hosted_zone.name}"
  port                            = [8080, 50000][count.index]
  type                            = "HTTP"
  resource_path                   = "/"
  failure_threshold               = "3"
  enable_sni                      = false
  request_interval                = "30"
  measure_latency                 = false
  insufficient_data_health_status = "Healthy"
  regions = ["sa-east-1", "us-west-1", "us-west-2", "ap-northeast-1", "ap-southeast-1", "eu-west-1", "us-east-1", "ap-southeast-2"]
  count = 2
  tags = {
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
