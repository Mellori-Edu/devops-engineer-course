module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.1.0"
  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs              = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets  = ["10.1.160.0/20", "10.1.176.0/20", "10.1.192.0/20"]
  public_subnets   = ["10.1.208.0/20", "10.1.224.0/20", "10.1.240.0/20"]
  database_subnets = ["10.1.112.0/20", "10.1.128.0/20", "10.1.144.0/20"]

  enable_nat_gateway     = false
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  // https://aws.amazon.com/premiumsupport/knowledge-center/vpc-enable-private-hosted-zone/
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}