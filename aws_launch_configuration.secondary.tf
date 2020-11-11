resource "aws_launch_configuration" "secondary" {
  image_id = lookup(var.aws_amis, var.aws_region)

  instance_type = var.artifactory_instance_type

  # The name of our SSH keypair we created above.
  key_name = var.key_name

  security_groups = [aws_security_group.default.id]

  associate_public_ip_address = true

  user_data = data.template_file.secondary_init.rendered

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.volume_size
    delete_on_termination = true
    encrypted             = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
