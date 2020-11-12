#RDS to for Artifactory
resource "aws_db_instance" "default" {
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp2"
  storage_encrypted      = true
  engine                 = "mysql"
  engine_version         = "5.5"
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_user
  password               = var.db_password
  multi_az               = "false"
  vpc_security_group_ids = [aws_security_group.main_db_access.id]
  skip_final_snapshot    = "true"
  db_subnet_group_name   = aws_db_subnet_group.main_db_subnet_group.name

  tags = var.common_tags
}
