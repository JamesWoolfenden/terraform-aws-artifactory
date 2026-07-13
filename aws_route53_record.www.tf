resource "aws_route53_record" "www" {
  zone_id = var.dns.zone_id
  name    = var.dns.record
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
  }

}
