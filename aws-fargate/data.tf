data "aws_route53_zone" "route53_hosted_zone" {
  zone_id = var.route53_zone_id
  vpc_id  = var.vpc_id
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id
}

data "aws_efs_file_system" "efs" {
  file_system_id = "fs-0f5420fe"
}
