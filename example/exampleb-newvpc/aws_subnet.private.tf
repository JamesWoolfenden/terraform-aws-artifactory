# Private subnets for Artifactory instances and RDS - no public IPs.
# Outbound internet access (package installation at boot) is via the NAT
# gateway in aws_nat_gateway.default.tf, not a direct route to the internet
# gateway.
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
