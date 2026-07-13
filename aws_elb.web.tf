locals {
  alb_subnet_ids = length(var.network.alb_subnet_ids) > 0 ? var.network.alb_subnet_ids : var.network.subnet_ids
}

resource "aws_lb" "web" {
  name                       = var.load_balancer.name
  load_balancer_type         = "application"
  subnets                    = local.alb_subnet_ids
  security_groups            = [aws_security_group.elb.id]
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "alb"
    enabled = true
  }

  depends_on = [aws_s3_bucket_policy.alb_logs]
}

resource "aws_lb_target_group" "web" {
  name        = substr("${var.load_balancer.name}-tg", 0, 32)
  port        = 8082
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.network.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 15
    interval            = 30
    path                = "/ui/login/"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.load_balancer.ssl_certificate_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_wafv2_web_acl" "web" {
  name  = "${var.load_balancer.name}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # CVE-2021-44228 (Log4Shell): blocks the JNDI lookup patterns this rule group targets.
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.load_balancer.name}-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "web" {
  resource_arn = aws_lb.web.arn
  web_acl_arn  = aws_wafv2_web_acl.web.arn
}

# Name must be prefixed "aws-waf-logs-" - required by the WAFv2 logging API.
resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.load_balancer.name}"
  retention_in_days = 365
  kms_key_id        = var.kms_key
}

resource "aws_wafv2_web_acl_logging_configuration" "web" {
  resource_arn            = aws_wafv2_web_acl.web.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
}
