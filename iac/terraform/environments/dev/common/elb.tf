# Security group
resource "aws_security_group" "elb" {
  count       = local.elb_created ? 1 : 0
  name        = "${local.name_prefix}-sg-elb"
  description = "Security group allow access the ELB."
  vpc_id      = module.vpc[0].vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow from anywhere"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Application LB
resource "aws_lb" "this" {
  count                      = local.elb_created ? 1 : 0
  name                       = "${local.name_prefix}-alb"
  load_balancer_type         = var.elb_type
  security_groups            = [aws_security_group.elb[0].id]
  subnets                    = module.vpc[0].public_subnets
  idle_timeout               = 60
  enable_deletion_protection = false
  tags                       = local.common_tags

  depends_on = [
    aws_security_group.elb
  ]
}

# Target group
resource "aws_lb_target_group" "tg" {
  for_each    = local.elb_created ? toset(["tg-1", "tg-2"]) : toset([])
  name        = "${local.name_prefix}-${each.value}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc[0].vpc_id
  health_check {
    enabled             = true
    path                = var.elb_healthcheck_settings.path
    healthy_threshold   = var.elb_healthcheck_settings.healthy_threshold
    unhealthy_threshold = var.elb_healthcheck_settings.unhealthy_threshold
    interval            = var.elb_healthcheck_settings.interval
    timeout             = var.elb_healthcheck_settings.timeout
  }
  tags = local.common_tags
}

# ALB Listener
resource "aws_lb_listener" "http" {
  count             = local.elb_created ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["tg-1"].arn
  }



  depends_on = [
    aws_security_group.elb,
    aws_lb_target_group.tg
  ]

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}