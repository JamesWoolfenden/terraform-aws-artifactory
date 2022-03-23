
resource "aws_launch_configuration" "master" {

  image_id      = data.aws_ami.amazon_linux_2_ami.id
  instance_type = var.instance_type

  # The name of our SSH keypair we created above.
  key_name        = var.key_name
  security_groups = [aws_security_group.default.id]
  # tfsec:ignore:AWS012
  associate_public_ip_address = true
  user_data                   = data.template_file.init.rendered
  iam_instance_profile        = aws_iam_instance_profile.art.name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.volume_size
    delete_on_termination = true
    encrypted             = true
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}
