#RDS to for Artifactory
resource "aws_db_instance" "default" {
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

  tags = var.common_tags
}
variable "monitoring_interval" {
  type        = string
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  default     = 30

  validation {
    condition     = can(regex("0|1|5|10|15|30|60", var.monitoring_interval))
    error_message = "Valid Values: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  type    = string
  default = ""
}
