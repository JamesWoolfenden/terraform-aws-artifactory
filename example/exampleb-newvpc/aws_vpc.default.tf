
# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = join(",", var.vpc_cidr)
}
