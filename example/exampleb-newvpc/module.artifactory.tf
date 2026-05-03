module "artifactory" {
  source             = "../../"
  subnet_ids         = [aws_subnet.default.id, aws_subnet.default_2.id, aws_subnet.default_3.id]
  vpc_id             = aws_vpc.default.id
  vpc_cidr           = var.vpc_cidr
  db_password        = random_string.db_password.result
  kms_key            = aws_kms_key.example
  bucket_name        = var.bucket_name
  instance_type      = var.instance_type
  ssh_access         = var.ssh_access
  access_cidr        = var.access_cidr
  ssl_certificate_id = var.ssl_certificate_id
  zone_id            = var.zone_id
  record             = var.record
}

resource "random_string" "db_password" {
  length = 12
}
