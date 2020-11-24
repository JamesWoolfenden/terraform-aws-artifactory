

#RDS Security Group
resource "aws_security_group" "main_db_access" {
  description = "Allow access to the database"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_db_access" {
  type = "ingress"

  from_port   = "3306"
  to_port     = "3306"
  protocol    = "tcp"
  cidr_blocks = var.vpc_cidr

  security_group_id = aws_security_group.main_db_access.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main_db_access.id
}

resource "aws_db_subnet_group" "main_db_subnet_group" {
  name        = "db-subnetgrp"
  description = "RDS subnet group"
  subnet_ids  = var.subnet_ids
}
