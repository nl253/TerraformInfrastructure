output "task" {
  value = aws_ecs_task_definition.task
}

output "cluster" {
  value = aws_ecs_cluster.cluster
}

output "fs" {
  value = aws_efs_file_system.efs
}
