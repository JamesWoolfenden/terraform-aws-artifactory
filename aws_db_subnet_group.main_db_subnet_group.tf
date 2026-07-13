resource "aws_db_subnet_group" "main_db_subnet_group" {
  name        = "db-subnetgrp"
  description = "RDS subnet group"
  subnet_ids  = var.network.subnet_ids
}
