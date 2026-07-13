resource "aws_db_instance" "default" {
  allocated_storage                   = var.database.allocated_storage
  auto_minor_version_upgrade          = true
  storage_type                        = var.database.storage_type
  monitoring_interval                 = var.database.monitoring_interval
  monitoring_role_arn                 = var.database.monitoring_role_arn
  storage_encrypted                   = true
  kms_key_id                          = var.kms_key
  engine                              = var.database.engine
  engine_version                      = var.database.engine_version
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general"]
  instance_class                      = var.database.instance_class
  db_name                             = var.database.name
  username                            = var.database.user
  password                            = var.database.password
  multi_az                            = true
  max_allocated_storage               = var.database.allocated_storage
  backup_retention_period             = 7
  iam_database_authentication_enabled = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = var.kms_key
  vpc_security_group_ids              = [aws_security_group.main_db_access.id]
  skip_final_snapshot                 = var.database.skip_final_snapshot
  deletion_protection                 = true
  db_subnet_group_name                = aws_db_subnet_group.main_db_subnet_group.name
  copy_tags_to_snapshot               = true

  lifecycle {
    prevent_destroy = true
  }
}
