resource "aws_codedeploy_app" "laravel_demo" {
  count = local.codedeploy_created ? 1 : 0

  name             = "${local.name_prefix}-laravel-demo"
  compute_platform = var.compute_platform
}

resource "aws_codedeploy_deployment_group" "laravel_demo" {
  count                  = local.codedeploy_created ? 1 : 0
  app_name               = aws_codedeploy_app.laravel_demo[0].name
  deployment_group_name  = "${local.name_prefix}-laravel-demo"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = var.deployment_config_name


  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = var.action_on_timeout
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }
  deployment_style {
    deployment_option = var.deployment_option
    deployment_type   = var.deployment_type
  }
  ecs_service {
    cluster_name = local.ecs_cluster_name
    service_name = aws_ecs_service.laravel_demo[0].name
  }
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = aws_lb_listener.http[*].arn
      }
      target_group {
        name = aws_lb_target_group.tg["tg-1"].name
      }
      target_group {
        name = aws_lb_target_group.tg["tg-2"].name
      }
    }
  }
}