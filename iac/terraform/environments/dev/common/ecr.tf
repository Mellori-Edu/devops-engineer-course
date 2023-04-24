locals {
  ecr_rep_names = [
    "${var.project_name}-laravel-demo-php",
    "${var.project_name}-laravel-demo-nginx"
  ]
}

resource "aws_ecr_repository" "ecr_repo" {
<<<<<<< HEAD
  for_each = local.ecs_service_created ? toset(local.ecr_rep_names) : []
=======
  for_each = var.ecs_service_created ? toset(local.ecr_rep_names) : []
>>>>>>> 619ca9f ([update] - to update terraform)
  name     = each.value

  tags = local.common_tags
}
