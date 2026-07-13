# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = var.load_balancer.name
  description = "Used in the terraform"
  vpc_id      = var.network.vpc_id

  # HTTPS access from anywhere
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.network.access_cidr
  }

  # The ALB only forwards to Artifactory's target group port within the VPC -
  # it never needs to reach the internet.
  egress {
    description = "Allow HTTP to the Artifactory target group within the VPC"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = var.network.vpc_cidr
  }
}
