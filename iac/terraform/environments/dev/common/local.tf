locals {
    common_tags = {
        terraform = true
        environment = var.env
        project = var.project_name
    }
}