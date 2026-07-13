resource "aws_autoscaling_group" "art" {
  name                      = var.autoscaling_group_name
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = var.network.subnet_ids

  launch_template {
    id      = aws_launch_template.master.id
    version = aws_launch_template.master.latest_version
  }

  target_group_arns = [
    aws_lb_target_group.web.arn
  ]
  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = var.autoscaling_group_name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.art.id
  lb_target_group_arn    = aws_lb_target_group.web.arn
}
