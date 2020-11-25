
data "template_file" "init" {
  template = file("${path.module}/userdata.sh")

  vars = {
    s3_bucket_name          = aws_s3_bucket.b.id
    s3_bucket_region        = aws_s3_bucket.b.region
    db_url                  = aws_db_instance.default.endpoint
    db_name                 = aws_db_instance.default.name
    db_user                 = aws_db_instance.default.username
    db_password             = aws_db_instance.default.password
    master_key              = var.master_key
    artifactory_server_name = var.artifactory_server_name
    EXTRA_JAVA_OPTS         = var.extra_java_options
  }
}
