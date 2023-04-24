variable "env" {
  default = "SHORT_ENV"
}

variable "project_name" {
  default = "PROJECT_NAME"
}


variable "aws_region" {
  default = "ap-southeast-1"
}


# VPC settings

variable "vpc_created" {
  type    = bool
  default = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}


# Ec2 settings

variable "ec2_created" {
  type    = string
  default = true
}

variable "ami_id" {
  type    = string
  default = "ami-xxxx"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "devops"
}

# ELB settings

variable "elb_created" {
  type    = bool
  default = true
}
variable "elb_is_internal" { default = false }
variable "elb_type" { default = "application" }

variable "elb_healthcheck_settings" {
  type = map(string)
  default = {
    path                = "/healthcheck"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 10
  }
}



# ECS settings
variable "ecs_created" {
  type    = bool
  default = true
}

variable "ecs_service_created" {
  type    = bool
  default = true
}

variable "ecs_asg_settings" {
  type = map(string)
  default = {
    min_size         = 2
    max_size         = 2
    desized_capacity = 2

    ami_id        = "ami-0920ef3608aa17d63"
    instance_type = "t3.small"

    ebs_volume_size = 30,

  }

}



# CodeDeploy

variable "codedeploy_created" {
  type    = string
  default = true
}
variable "codedeploy_policies_arn" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  ]
}

variable "ecs_deployment_controller_type" {
  type    = string
  default = "CODE_DEPLOY"
}

variable "termination_wait_time_in_minutes" {
  type    = number
  default = 30
}


variable "compute_platform" {
  type    = string
  default = "ECS"
}
variable "deployment_config_name" {
  type    = string
  default = "CodeDeployDefault.ECSAllAtOnce"
}

# CONTINUE_DEPLOYMENT || STOP_DEPLOYMENT
variable "action_on_timeout" {
  type    = string
  default = "CONTINUE_DEPLOYMENT"
}


# WITH_TRAFFIC_CONTROL || WITHOUT_TRAFFIC_CONTROL
variable "deployment_option" {
  type    = string
  default = "WITH_TRAFFIC_CONTROL"
}

# IN_PLACE || BLUE_GREEN
variable "deployment_type" {
  type    = string
  default = "BLUE_GREEN"
}


variable "codebuild_created" {
  type    = bool
  default = true
}


variable "codepipeline_created" {
  type    = bool
  default = false
}


variable "cloudfront_created" {
  type    = bool
  default = true
}


variable "db_created" {
  type    = bool
  default = true
}