variable "env" {
  default = "dev"
}

variable "project_name" {
  default = "lamhaison"
}

variable "aws_profile" {
  default = "YOUR_PROFILE"
}

variable "aws_region" {
  default = "ap-southeast-1"
}


# VPC settings
variable "vpc_cidr" {
  type = string
  default = "10.1.0.0/16"
}


# Ec2 settings
variable "ami_id" {
  type = string
  default = "ami-xxxx"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
  default = "devops"
}