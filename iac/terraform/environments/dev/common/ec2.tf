resource "aws_instance" "demo" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name                = var.key_name
  disable_api_termination = true
  subnet_id               = module.vpc.public_subnets[0]

  tags = {
    Name = "${local.name_prefix}-HelloWorld"
  }
}