resource "aws_db_instance" "db" {
  allocated_storage                   = var.db_storage
  skip_final_snapshot                 = true
  storage_type                        = var.db_storage_type
  publicly_accessible                 = var.db_public
  multi_az                            = var.db_multi_az
  max_allocated_storage               = var.db_max_storage
  engine                              = var.db_engine
  storage_encrypted                   = var.db_encrypted
  instance_class                      = var.db_instance_type
  iam_database_authentication_enabled = true
  name                                = var.db_name
  username                            = var.db_username
  copy_tags_to_snapshot               = true
  apply_immediately                   = true
  performance_insights_enabled        = var.db_performance_insights
  auto_minor_version_upgrade          = true
  password                            = var.db_password
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
