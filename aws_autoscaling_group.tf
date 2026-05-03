resource "aws_autoscaling_group" "art" {
  # checkov:skip=CKV_AWS_153: Artifactory is accessed via ELB, not a target group
  name                      = var.autoscaling_group_name
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = var.subnet_ids

  launch_template {
    id      = aws_launch_template.master.id
    version = "$Latest"
  }

  load_balancers = [
    aws_elb.web.name
  ]
  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  # checkov:skip=CKV2_AWS_15: Artifactory uses Classic ELB, not Application/Network LB with target groups
  autoscaling_group_name = aws_autoscaling_group.art.id
  elb                    = aws_elb.web.id
}
