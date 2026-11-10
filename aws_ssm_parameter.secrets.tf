# Secrets are fetched by the instance at boot instead of being rendered into
# user_data (which is readable via the launch template and EC2 API).
resource "aws_ssm_parameter" "db_password" {
  name   = "/${var.profile_name}/db-password"
  type   = "SecureString"
  key_id = var.kms_key
  value  = aws_db_instance.default.password
}

resource "aws_ssm_parameter" "master_key" {
  name   = "/${var.profile_name}/master-key"
  type   = "SecureString"
  key_id = var.kms_key
  value  = var.master_key
}
