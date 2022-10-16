terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Saving state on S3 Remote state.
  backend "s3" {
    bucket                  = "PROJECT_NAME-testing"
    key                     = "common/terraform.state"
    profile                 = "PROJECT_NAME"
    region                  = "ap-southeast-1"
    skip_metadata_api_check = true
  }

}

provider "aws" {
  profile = "PROJECT_NAME"
  region  = "ap-southeast-1"
}
