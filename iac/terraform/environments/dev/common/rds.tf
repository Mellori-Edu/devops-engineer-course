resource "aws_security_group" "rds" {
  count       = local.db_created ? 1 : 0
  name        = "${local.name_prefix}-sg-rds"
  description = "Security group allow access on the ECS service from the ECS container service"
  vpc_id      = module.vpc[0].vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs[0].id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
  depends_on = [
    aws_security_group.ecs
  ]
}


resource "aws_db_instance" "default" {
  count                = local.db_created ? 1 : 0
  allocated_storage    = 10
  identifier           = "${local.name_prefix}-db-instance"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "laravel"
  username             = "laravel"
  password             = "zp$37NHaDzdHWBQd"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = module.vpc[0].database_subnet_group_name

  vpc_security_group_ids = [
    aws_security_group.rds[0].id
  ]

  depends_on = [
    aws_security_group.rds
  ]
}