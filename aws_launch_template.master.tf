resource "aws_launch_template" "master" {
  # checkov:skip=CKV_AWS_88: example only
  image_id      = data.aws_ami.amazon_linux_2_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.art.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.default.id]
  }

  user_data = base64encode(local.user_data)

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = var.volume_size
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}
