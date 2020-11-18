module "artifactory" {
  source            = "../../"
  common_tags       = var.common_tags
  subnet_ids        = [aws_subnet.default.id, aws_subnet.default_2.id, aws_subnet.default_3.id]
  vpc_id            = aws_vpc.default.id
  vpc_cidr          = var.vpc_cidr
  availability_zone = data.aws_availability_zones.available
}
