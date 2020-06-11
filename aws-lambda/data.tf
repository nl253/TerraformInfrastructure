data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.vpc.id
}

data "aws_security_groups" "security_groups" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id == null ? data.aws_vpc.vpc.id : var.vpc_id]
  }
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_sns_topic" "dead_letter_topic" {
  name = var.dead_letter_topic_name
}

data "aws_caller_identity" "id" {}

data "archive_file" "zip" {
  output_path = "index.zip"
  type        = "zip"
  source_dir  = var.source_dir
}
