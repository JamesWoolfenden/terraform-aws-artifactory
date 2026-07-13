# checkov:skip=CKV_AWS_88: controlled via var.network.associate_public_ip; defaults true to preserve compatibility with examplea (default VPC, no NAT gateway) - set false when subnet_ids are private with NAT egress
resource "aws_launch_template" "master" {
  image_id      = data.aws_ami.amazon_linux_2_ami.id
  instance_type = var.instance.instance_type
  key_name      = var.instance.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.art.name
  }

  network_interfaces {
    associate_public_ip_address = var.network.associate_public_ip
    security_groups             = [aws_security_group.default.id]
  }

  user_data = base64encode(local.user_data)

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = var.instance.volume_size
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  lifecycle {
    create_before_destroy = true
  }
}
