resource "aws_route53_record" "instance" {
  count = var.instance_count

  zone_id = data.aws_route53_zone.chips-e2e-pilot.zone_id
  name    = "instance-${count.index + 1}.${var.service_subtype}.${var.service}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.chips-e2e-pilot[count.index].private_ip]
}
