# Create a VPC to launch our instances into
# holden:ignore:HLD_AWS_054
# holden:ignore:HLD_AWS_133
resource "aws_vpc" "default" {
  cidr_block = join(",", var.vpc_cidr)
}
