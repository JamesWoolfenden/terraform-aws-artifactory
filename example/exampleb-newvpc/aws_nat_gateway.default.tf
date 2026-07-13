# NAT gateway lives in a public subnet and gives the private subnets
# outbound-only internet access, so Artifactory instances don't need
# public IPs of their own.
# holden:ignore:HLD_AWS_116: associated with the NAT gateway below, not an instance
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.default]
}
