resource "aws_route53_zone" "webapp_zone" {
  name = "webapp.com"
}


resource "aws_route53_record" "root" {
  count = var.enable_aws_only ? 1 : 0
  zone_id = aws_route53_zone.webapp_zone.id
  name    = "www.webapp.com"
  type    = "A"
  records = ["1.2.3.4"]

  alias {
  name                   = aws_lb.webapp_lb[0].dns_name
  zone_id                = aws_lb.webapp_lb[0].zone_id  
  evaluate_target_health = true
}

}

