

#RDS Security Group
resource "aws_security_group" "main_db_access" {
  description = "Allow access to the database"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_db_access" {
  type = "ingress"

  from_port   = "3306"
  to_port     = "3306"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main_db_access.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main_db_access.id
}

resource "aws_db_subnet_group" "main_db_subnet_group" {
  name        = "db-subnetgrp"
  description = "RDS subnet group"
  subnet_ids  = var.subnet_ids
}

resource "aws_cloudformation_stack" "autoscaling_group" {
  name = "artifactory-asg"
  template_body = templatefile("${path.module}/template/autoscaling", {
    AvailabilityZones       = tolist([var.availability_zone[1], var.availability_zone[2]]),
    VPCZoneIdentifier       = tolist([var.subnet_ids[1], var.subnet_ids[2]]),
    LaunchConfigurationName = aws_launch_configuration.master.name,
    LoadBalancerNames       = aws_elb.web.name
  })
}

resource "aws_autoscaling_policy" "my_policy" {
  name                   = "my-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_cloudformation_stack.autoscaling_group.outputs["AsgName"]
}

resource "aws_cloudformation_stack" "autoscaling_group_secondary" {
  name = "artifactory-secondary-asg"
  template_body = templatefile("${path.module}/template/autoscaling_group_secondary", {
    AvailabilityZones       = tolist([var.availability_zone[1], var.availability_zone[2]]),
    VPCZoneIdentifier       = tolist([var.subnet_ids[1], var.subnet_ids[2]]),
    LaunchConfigurationName = aws_launch_configuration.master.name,
    LoadBalancerNames       = aws_elb.web.name,
    DesiredCapacity         = var.secondary_node_count
  })
}

resource "aws_autoscaling_policy" "my_secondary_policy" {
  name                   = "my-secondary-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_cloudformation_stack.autoscaling_group_secondary.outputs["SecondaryAsgName"]
}
