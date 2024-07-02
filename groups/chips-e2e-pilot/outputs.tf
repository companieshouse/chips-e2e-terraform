output "dns_names" {
  value = aws_route53_record.ec2_dns.*.name
}
