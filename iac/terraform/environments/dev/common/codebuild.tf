resource "aws_codebuild_project" "laravel_demo" {
  count                  = var.codebuild_created ? 1 : 0
  name                   = "${local.name_prefix}-laravel-demo"
  description            = "${local.name_prefix}-laravel-demo"
  badge_enabled          = false
  build_timeout          = 60
  concurrent_build_limit = 1
  project_visibility     = "PRIVATE"
  queued_timeout         = 480
  service_role           = aws_iam_role.ci_id_role["ci"].arn


<<<<<<< HEAD
=======


>>>>>>> lamhaison/main
  artifacts {
    encryption_disabled    = false
    name                   = "${local.name_prefix}-laravel-demo"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  cache {
    modes = []
    type  = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = "codebuild/buildspec.yml"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  tags = local.common_tags



}