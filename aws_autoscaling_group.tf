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


  timeouts {
    delete = "15m"
  }

}
