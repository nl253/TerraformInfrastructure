provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

resource "aws_db_instance" "db" {
  allocated_storage          = var.db_storage
  skip_final_snapshot        = true
  storage_type               = var.db_storage_type
  publicly_accessible        = var.db_public
  max_allocated_storage      = var.db_max_storage
  engine                     = var.db_engine
  storage_encrypted          = var.db_encrypted
  instance_class             = var.db_instance_type
  name                       = var.db_name
  username                   = var.db_username
  auto_minor_version_upgrade = true
  password                   = var.db_password
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
