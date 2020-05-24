data "aws_route53_zone" "route53_hosted_zone" {
  zone_id = var.route53_zone_id
  vpc_id  = var.vpc_id
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

