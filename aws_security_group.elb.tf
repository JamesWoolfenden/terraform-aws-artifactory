# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = var.elb_name
  description = "Used in the terraform"
  vpc_id      = var.vpc_id

  # HTTPS access from anywhere
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.access_cidr
  }

  # outbound internet access
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }
}
