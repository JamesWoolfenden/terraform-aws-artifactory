resource "aws_elb" "web" {
  #checkov:skip=CKV_AWS_92: "Ensure the ELB has access logging enabled"
  name = var.elb_name

  subnets         = var.subnet_ids
  security_groups = [aws_security_group.elb.id]

  listener {
    instance_port      = 8082
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl_certificate_id
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 15
    target              = "HTTP:8082/ui/login/"
    interval            = 30
  }

  tags = var.common_tags
}
