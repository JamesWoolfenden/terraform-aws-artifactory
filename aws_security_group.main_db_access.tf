#RDS Security Group
resource "aws_security_group" "main_db_access" {
  description = "Allow access to the database"
  vpc_id      = var.network.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "DB access rule"
    cidr_blocks = var.network.vpc_cidr
  }

  # RDS never initiates outbound connections on its own - enhanced monitoring
  # and CloudWatch log export both go through AWS's control plane, not this
  # ENI - so no egress rule is required.
}
