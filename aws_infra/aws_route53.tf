resource "aws_route53_zone" "webapp_zone" {
  name = "webapp.com"
}


resource "aws_route53_record" "root" {
  count = var.enable_aws_only ? 1 : 0
  zone_id = aws_route53_zone.webapp_zone.id
  name    = "www.webapp.com"
  type    = "A"

  alias {
  name                   = aws_lb.webapp_lb[0].dns_name
  zone_id                = aws_lb.webapp_lb[0].zone_id  
  evaluate_target_health = true
}
}

resource "aws_route53_record" "vm_records" {
  for_each = aws_instance.VM

  zone_id = aws_route53_zone.webapp_zone.id
  name    = "${lower(each.key)}.webapp.com" # Gera registros DNS para cada VM
  type    = "A"
  ttl     = 300
  records = [each.value.private_ip]
}


