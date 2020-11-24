resource "aws_elb" "web" {
  #checkov:skip=CKV_AWS_92: "Ensure the ELB has access logging enabled"
  name = var.elb_name

  subnets         = var.subnet_ids
  security_groups = [aws_security_group.elb.id]

  listener {
    instance_port     = 8081
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 15
    target              = "HTTP:80/artifactory/webapp/#/login"
    interval            = 30
  }

  tags = var.common_tags
}
