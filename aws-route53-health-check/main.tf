resource "aws_route53_health_check" "health_check" {
  port              = tolist(var.ports)[count.index]
  fqdn              = var.uri
  type              = "HTTP"
  reference_name    = "${var.app_name}-dns"
  measure_latency   = true
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"
  count             = length(tolist(var.ports))
  tags = {
    Name        = "Health Check ${var.app_name} ${count.index + 1} for ${var.uri} port ${tolist(var.ports)[count.index]}"
    Application = var.app_name
    Environment = var.env
  }
}
