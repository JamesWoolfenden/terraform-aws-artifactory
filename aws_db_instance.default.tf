resource "aws_db_instance" "default" {
  # checkov:skip=CKV_AWS_157: Cost
  # checkov:skip=CKV_AWS_118: Cost
  # checkov:skip=CKV_AWS_161: TODO
  #tfsec:ignore:AWS091
  allocated_storage               = var.db_allocated_storage
  storage_type                    = var.rds["storage_type"]
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  storage_encrypted               = true
  engine                          = var.rds["engine"]
  engine_version                  = var.rds["engine_version"]
  enabled_cloudwatch_logs_exports = ["audit", "error", "general"]
  instance_class                  = var.db_instance_class
  name                            = var.db_name
  username                        = var.db_user
  password                        = var.db_password
  multi_az                        = var.rds["multi_az"]
  vpc_security_group_ids          = [aws_security_group.main_db_access.id]
  skip_final_snapshot             = var.rds["skip_final_snapshot"]
  db_subnet_group_name            = aws_db_subnet_group.main_db_subnet_group.name
}
