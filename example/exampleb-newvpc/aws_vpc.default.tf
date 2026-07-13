# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block           = join(",", var.vpc_cidr)
  enable_dns_hostnames = true
}

# AWS auto-creates a default security group with this VPC that allows all
# traffic between members; explicitly manage it down to no rules (CIS 5.3 /
# Security Hub EC2.2) since nothing in this example should use it.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id
}
