variable "ec2_created" {
  type    = string
  default = false
}
resource "aws_instance" "demo" {
  count                   = var.ec2_created ? 1 : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = true
  subnet_id               = module.vpc[0].public_subnets[0]

  tags = {
    Name = "${local.name_prefix}-HelloWorld"
  }
}