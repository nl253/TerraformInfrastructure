resource "aws_route53_health_check" "health_check" {
  port              = tolist(var.ports)[count.index]
  fqdn              = var.uri
  type              = var.type
  reference_name    = "${var.app_name}-dns"
  measure_latency   = true
  resource_path     = var.path
  failure_threshold = "${var.max_failures}"
  request_interval  = "${var.request_interval}"
  count             = length(tolist(var.ports))
  tags = {
    Name        = "Health Check ${var.app_name} ${count.index + 1} for ${var.uri} port ${tolist(var.ports)[count.index]}"
    Application = var.app_name
    Environment = var.env
  }
}
