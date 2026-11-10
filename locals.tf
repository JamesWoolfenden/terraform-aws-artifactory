locals {
  user_data = templatefile("${path.module}/userdata.sh.template", {
    s3_bucket_name          = aws_s3_bucket.b.id
    s3_bucket_region        = aws_s3_bucket.b.region
    db_url                  = aws_db_instance.default.endpoint
    db_name                 = aws_db_instance.default.db_name
    db_user                 = aws_db_instance.default.username
    db_password_param       = aws_ssm_parameter.db_password.name
    master_key_param        = aws_ssm_parameter.master_key.name
    artifactory_server_name = var.artifactory_server_name
    artifactory_version     = var.instance.artifactory_version
    EXTRA_JAVA_OPTS         = var.instance.extra_java_options
  })
  alb_subnet_ids = length(var.network.alb_subnet_ids) > 0 ? var.network.alb_subnet_ids : var.network.subnet_ids
}
