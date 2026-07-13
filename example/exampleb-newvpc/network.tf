# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Private subnet for Artifactory instances and RDS - no public IPs.
# Outbound internet access (package installation at boot) is via the NAT
# gateway below, not a direct route to the internet gateway.
resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "default_2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "default_3" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
}

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

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default.id
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.default_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.default_3.id
  route_table_id = aws_route_table.private.id
}
