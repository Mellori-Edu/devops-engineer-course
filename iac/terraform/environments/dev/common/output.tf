output "vpc_name" {
  value = "${local.name_prefix}-vpc"
}

output "elb_dns_domain" {
  value = local.elb_created ? aws_lb.this[0].dns_name : null
}