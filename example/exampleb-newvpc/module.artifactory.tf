# holden:ignore:HLD_TF_073
# holden:ignore:HLD_TF_026
module "artifactory" {
  source = "../../"

  instance = {
    instance_type = var.instance_type
  }

  network = {
    vpc_id              = aws_vpc.default.id
    vpc_cidr            = var.vpc_cidr
    subnet_ids          = [aws_subnet.default.id, aws_subnet.default_2.id, aws_subnet.default_3.id]
    alb_subnet_ids      = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id]
    associate_public_ip = false
    ssh_access          = var.ssh_access
    access_cidr         = var.access_cidr
  }

  database = {
    password            = random_string.db_password.result
    monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  }

  load_balancer = {
    ssl_certificate_id = var.ssl_certificate_id
  }

  dns = {
    zone_id = var.zone_id
    record  = var.record
  }

  bucket_name = var.bucket_name
  kms_key     = aws_kms_key.artifactory.arn
  master_key  = random_id.master_key.hex
}

resource "random_string" "db_password" {
  length = 12
}

resource "random_id" "master_key" {
  byte_length = 16
}
