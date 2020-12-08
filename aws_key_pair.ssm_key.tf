resource "aws_key_pair" "ssm_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh
  tags       = var.common_tags
}

resource "local_file" "public_ssh" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "id_rsa.pub"
}

resource "local_file" "private_ssh" {
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "600"
  filename        = "id_rsa"
}
