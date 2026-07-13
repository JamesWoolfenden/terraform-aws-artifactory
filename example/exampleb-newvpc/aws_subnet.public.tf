# Public subnets for the internet-facing ALB and the NAT gateway only -
# no instances are placed here.
# holden:ignore:HLD_AWS_052: public by design - hosts the ALB and NAT gateway, no instances
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone       = aws_subnet.default.availability_zone
}

# holden:ignore:HLD_AWS_052: public by design - hosts the ALB, no instances
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
}

# holden:ignore:HLD_AWS_052: public by design - hosts the ALB, no instances
resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.103.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_vpc.default.main_route_table_id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_vpc.default.main_route_table_id
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_vpc.default.main_route_table_id
}
