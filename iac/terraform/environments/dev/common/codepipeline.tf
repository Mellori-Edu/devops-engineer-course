# resource "aws_s3_bucket" "codepipline_laravel_demo" {
#   bucket = "${local.name_prefix}-codepipeline-laravel-demo"

#   tags = local.common_tags
# }


# resource "aws_codepipeline" "laravel_demo" {
#     count = local.codepipeline_created ? 1 : 0
#     name        = "${local.name_prefix}-laravel-demo"
#     role_arn    = aws_iam_role.code_pipeline_role["codepipeline"].arn
#     tags     = local.common_tags

#     artifact_store {
#         location = aws_s3_bucket.codepipline_laravel_demo.id
#         type     = "S3"
#     }

#     stage {
#         name = "Source"

#         action {
#             category         = "Source"
#             configuration    = {
#                 "Branch"               = "main"
#                 "OAuthToken"           = ""
#                 "Owner"                = "lamhaison"
#                 "PollForSourceChanges" = "false"
#                 "Repo"                 = "devops-engineer-course"
#             }
#             input_artifacts  = []
#             name             = "Source"
#             namespace        = "SourceVariables"
#             output_artifacts = [
#                 "SourceArtifact",
#             ]
#             owner            = "ThirdParty"
#             provider         = "GitHub"
#             region           = var.aws_region
#             run_order        = 1
#             version          = "1"
#         }
#     }
#     stage {
#         name = "Build"

#         action {
#             category         = "Build"
#             configuration    = {
#                 "ProjectName" = "${local.name_prefix}-laravel-demo"
#             }
#             input_artifacts  = [
#                 "SourceArtifact",
#             ]
#             name             = "Build"
#             namespace        = "BuildVariables"
#             output_artifacts = [
#                 "BuildArtifact",
#             ]
#             owner            = "AWS"
#             provider         = "CodeBuild"
#             region           = var.aws_region
#             run_order        = 1
#             version          = "1"
#         }
#     }
#     stage {
#         name = "Deploy"

#         action {
#             category         = "Deploy"
#             configuration    = {
#                 "ApplicationName"     = "${local.name_prefix}-laravel-demo"
#                 "DeploymentGroupName" = "${local.name_prefix}-laravel-demo"
#             }
#             input_artifacts  = [
#                 "BuildArtifact",
#             ]
#             name             = "Deploy"
#             namespace        = "DeployVariables"
#             output_artifacts = []
#             owner            = "AWS"
#             provider         = "CodeDeploy"
#             region           = var.aws_region
#             run_order        = 1
#             version          = "1"
#         }
#     }
# }
