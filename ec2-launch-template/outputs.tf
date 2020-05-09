output "ec2_template" {
  value = aws_launch_template.spot_fleet_fleet_launch_template
}

output "lb_target" {
  value = aws_lb_target_group.target_group
}

output "ec2_template_spot" {
  value = aws_launch_template.spot_fleet_fleet_launch_template
}

output "load_balancer" {
  value = aws_lb.load_balancer
}
