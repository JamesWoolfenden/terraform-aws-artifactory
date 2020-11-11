data "template_file" "secondary_init" {
  template = file("userdata.sh")

  vars = {
    s3_bucket_name          = aws_s3_bucket.b.id
    s3_bucket_region        = aws_s3_bucket.b.region
    s3_access_key           = aws_iam_access_key.s3.id
    s3_secret_key           = aws_iam_access_key.s3.secret
    db_url                  = aws_db_instance.default.endpoint
    db_name                 = aws_db_instance.default.name
    db_user                 = aws_db_instance.default.username
    db_password             = aws_db_instance.default.password
    master_key              = var.master_key
    artifactory_version     = var.artifactory_version
    artifactory_license_1   = var.artifactory_license_1
    artifactory_license_2   = var.artifactory_license_2
    artifactory_license_3   = var.artifactory_license_3
    artifactory_license_4   = var.artifactory_license_4
    artifactory_license_5   = var.artifactory_license_5
    ssl_certificate         = var.ssl_certificate
    ssl_certificate_key     = var.ssl_certificate_key
    certificate_domain      = var.certificate_domain
    artifactory_server_name = var.artifactory_server_name
    EXTRA_JAVA_OPTS         = var.extra_java_options
    ISPRIMARY               = "false"
  }
}
