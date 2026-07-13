# holden:ignore:HLD_TF_073: this is the example calling the module it lives
# inside of, not a reusable module itself - the module's own scope is
# assessed (and intentionally accepted) at the root via .holden.yaml
# holden:ignore:HLD_TF_026: "../../" is unavoidable here - this example
# calls its own parent module, which by definition lives two directories up
module "artifactory" {
  source = "../../"

  instance = {
    instance_type = var.instance_type
  }

  network = {
    vpc_id      = var.vpc_id
    vpc_cidr    = var.vpc_cidr
    subnet_ids  = var.subnet_ids
    ssh_access  = [module.ip.cidr]
    access_cidr = [module.ip.cidr]
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

  bucket_name = "artifactory-${data.aws_caller_identity.current.account_id}"
  kms_key     = aws_kms_key.artifactory.arn
  master_key  = random_id.master_key.hex
}

resource "random_string" "db_password" {
  length = 12
}

resource "random_id" "master_key" {
  byte_length = 16
}
