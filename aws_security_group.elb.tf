# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = var.elb_name
  description = "Used in the terraform"
  vpc_id      = var.vpc_id

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.access_cidr
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
