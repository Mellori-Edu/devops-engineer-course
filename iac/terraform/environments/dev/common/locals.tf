locals {
  common_tags = {
    terraform   = true
    environment = var.env
    project     = var.project_name
  }

  name_prefix = "${var.project_name}-${var.env}"
}


locals {
  elb_created = var.vpc_created && var.elb_created
  ecs_created = var.vpc_created && var.elb_created && var.ecs_created
  ecs_service_created = local.ecs_created && var.ecs_service_created
  codedeploy_created = local.ecs_service_created && var.codedeploy_created
  codepipeline_created = var.codebuild_created && var.codepipeline_created

}
