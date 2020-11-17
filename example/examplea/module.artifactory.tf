module "artifactory" {
  source            = "../../"
  common_tags       = var.common_tags
  subnet_ids        = var.subnet_ids
  vpc_id            = var.vpc_id
  vpc_cidr          = var.vpc_cidr
  availability_zone = data.aws_availability_zones.available
}
