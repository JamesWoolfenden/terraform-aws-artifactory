resource "aws_autoscaling_group" "art" {
  name                      = "artifactory autoscaling group"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.master.name
  vpc_zone_identifier       = var.subnet_ids

  load_balancers = [
    aws_elb.web.name
  ]
  timeouts {
    delete = "15m"
  }

}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.art.id
  elb                    = aws_elb.web.id
}
