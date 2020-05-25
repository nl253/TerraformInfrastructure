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

resource "aws_ecs_service" "service" {
  depends_on                        = [module.security_group.security_group, module.alb.alb, module.alb.target_groups, module.alb.listeners]
  name                              = "${var.app_name}-service"
  task_definition                   = aws_ecs_task_definition.task.arn
  cluster                           = aws_ecs_cluster.cluster.id
  platform_version                  = "1.4.0"
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 120
  network_configuration {
    subnets          = [tolist(data.aws_subnet_ids.subnet_ids.ids)[0]]
    security_groups  = [module.security_group.security_group.id]
    assign_public_ip = true
  }
  load_balancer {
    container_name   = "${var.app_name}-app"
    container_port   = 8080
    target_group_arn = module.alb.target_groups[0].arn
  }
  load_balancer {
    container_name   = "${var.app_name}-app"
    container_port   = 50000
    target_group_arn = module.alb.target_groups[1].arn
  }
}

resource "aws_ecs_task_definition" "task" {
  depends_on = [module.security_group.security_group]
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
  task_role_arn            = module.task_role.role.arn
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.task_memory
  cpu                      = var.task_cpu
  family                   = "${var.app_name}-task"

  volume {
    name = "${var.app_name}-storage"
    efs_volume_configuration {
      file_system_id = module.efs.efs.id
      root_directory = "/"
    }
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
