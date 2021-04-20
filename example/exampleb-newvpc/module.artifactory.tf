module "artifactory" {
  source            = "../../"
  common_tags       = var.common_tags
  subnet_ids        = [aws_subnet.default.id, aws_subnet.default_2.id, aws_subnet.default_3.id]
  vpc_id            = aws_vpc.default.id
  vpc_cidr          = var.vpc_cidr
  db_password       = random_string.db_password.result
  availability_zone = data.aws_availability_zones.available
}


resource "random_string" "db_password" {
  length = 12
}
