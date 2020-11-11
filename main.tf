
# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "artifactory_sg"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from the VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from the VPC
  ingress {
    from_port   = 10001
    to_port     = 10001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#RDS Security Group
resource "aws_security_group" "main_db_access" {
  description = "Allow access to the database"
  vpc_id      = aws_vpc.default.id
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
  subnet_ids  = [aws_subnet.default.id, aws_subnet.default_2.id, aws_subnet.default_3.id]

}

#RDS to for Artifactory
resource "aws_db_instance" "default" {
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.5"
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_user
  password               = var.db_password
  multi_az               = "false"
  vpc_security_group_ids = [aws_security_group.main_db_access.id]
  skip_final_snapshot    = "true"
  db_subnet_group_name   = aws_db_subnet_group.main_db_subnet_group.name
}



resource "aws_cloudformation_stack" "autoscaling_group" {
  name          = "artifactory-asg"
  template_body = templatefile("${path.module}/template/autoscaling", {
    AvailabilityZones       = tolist([aws_subnet.default_2.availability_zone, aws_subnet.default_3.availability_zone]),
    VPCZoneIdentifier       = tolist([aws_subnet.default_2.id, aws_subnet.default_3.id]),
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
  name          = "artifactory-secondary-asg"
  template_body = templatefile("${path.module}/template/autoscaling_group_secondary",{
    AvailabilityZones       = tolist([aws_subnet.default_2.availability_zone, aws_subnet.default_3.availability_zone]),
    VPCZoneIdentifier       = tolist([aws_subnet.default_2.id, aws_subnet.default_3.id]),
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
