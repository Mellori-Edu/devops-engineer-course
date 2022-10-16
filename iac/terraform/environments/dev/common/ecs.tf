locals {
  ecs_cluster_name = "${local.name_prefix}-ecs-cluster"
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  count = local.ecs_created ? 1 : 0
  name  = local.ecs_cluster_name
  tags  = local.common_tags
}


resource "aws_security_group" "ecs" {
  count       = local.ecs_created ? 1 : 0
  name        = "${local.name_prefix}-sg-ecs"
  description = "Security group allow access on the ECS service from the ALB."
  vpc_id      = module.vpc[0].vpc_id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb[0].id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
  depends_on = [
    aws_security_group.elb
  ]
}


resource "aws_launch_template" "launch_template" {
  count = local.ecs_created ? 1 : 0
  name  = "${local.name_prefix}-ecs-launching-template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = "true"
      volume_size           = var.ecs_asg_settings.ebs_volume_size
      volume_type           = "gp2"
      encrypted             = "false"
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination              = false
  image_id                             = var.ecs_asg_settings.ami_id
  instance_type                        = var.ecs_asg_settings.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }


  key_name = var.key_name

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs[0].id]
  }

  user_data = filebase64("./scripts/ecs.tpl")

  tags = merge({ "Name" = "${local.name_prefix}-launch-template" }, local.common_tags)
}



resource "aws_autoscaling_group" "asg-ecs-cluster" {
  count                     = local.ecs_created ? 1 : 0
  name                      = "${local.name_prefix}-asg-ecs-cluster"
  desired_capacity          = var.ecs_asg_settings.desized_capacity
  max_size                  = var.ecs_asg_settings.min_size
  min_size                  = var.ecs_asg_settings.max_size
  vpc_zone_identifier       = module.vpc[0].public_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 0
  target_group_arns         = []
  termination_policies = [
    "OldestInstance"
  ]

  launch_template {
    id      = aws_launch_template.launch_template[0].id
    version = "$Latest"
  }

  depends_on = [
    aws_launch_template.launch_template
  ]
  tag {
    key                 = "Description"
    propagate_at_launch = true
    value               = "This is the autoscaling group for the ecs ${local.ecs_cluster_name}"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "ECS Instance of asg ${local.name_prefix}-asg-ecs-cluster"
  }

  tag {
    key                 = "Manage_by"
    propagate_at_launch = true
    value               = "Terraform"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = true
    value               = var.env
  }


  lifecycle {
    ignore_changes = [
      desired_capacity,
    ]
  }
}

resource "aws_cloudwatch_log_group" "laravel_demo" {
  name = "/ecs/${local.name_prefix}-laravel-demo"
  tags = local.common_tags
}


# ECS TaskDefinition
resource "aws_ecs_task_definition" "laravel_demo" {
  count                    = local.ecs_service_created ? 1 : 0
  family                   = "${local.name_prefix}-laravel-demo"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  task_role_arn            = aws_iam_role.ecs_role["task"].arn
  execution_role_arn       = aws_iam_role.ecs_role["execution"].arn
  container_definitions = jsonencode([
    {
      name              = "nginx"
      image             = "nginx:latest",
      memoryReservation = 50,
      portMappings = [
        {
          hostPort      = 0
          protocol      = "tcp"
          containerPort = 80
        }
      ]
    }
  ])
  tags = local.common_tags
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ECS Service
resource "aws_ecs_service" "laravel_demo" {
  count           = local.ecs_service_created ? 1 : 0
  name            = "${local.name_prefix}-laravel-demo"
  cluster         = aws_ecs_cluster.ecs_cluster[0].id
  task_definition = aws_ecs_task_definition.laravel_demo[0].arn
  desired_count   = 1
  launch_type     = "EC2"
  propagate_tags  = "SERVICE"
  tags            = local.common_tags
  load_balancer {
    target_group_arn = aws_lb_target_group.tg["tg-1"].arn
    container_name   = "nginx"
    container_port   = 80
  }

  deployment_controller {
    type = var.ecs_deployment_controller_type
  }
  lifecycle {
    ignore_changes = [network_configuration, desired_count, task_definition, load_balancer]
  }
}



