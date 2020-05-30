resource "aws_route53_health_check" "health_check" {
  port              = tolist(var.ports)[count.index]
  fqdn              = var.domain
  type              = var.type
  reference_name    = "${substr(replace(replace(replace(var.app_name, "-", ""), "_", ""), " ", ""), 0, 22)}-dns"
  measure_latency   = true
  resource_path     = var.path
  failure_threshold = "${var.max_failures}"
  request_interval  = "${var.request_interval}"
  count             = length(tolist(var.ports))
  tags = {
    Name        = "Health Check ${var.app_name} ${count.index + 1} for ${lower(var.type)}://${var.domain}:${tolist(var.ports)[count.index]}"
    Application = var.app_name
    Environment = var.env
  }
}
