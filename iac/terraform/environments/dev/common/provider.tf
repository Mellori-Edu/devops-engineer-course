terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Saving state on S3 Remote state.
  backend "s3" {
    bucket                  = "lamhaison-testing"
    key                     = "common/terraform.state"
    region                  = "ap-southeast-1"
  }

}

provider "aws" {
  region  = "ap-southeast-1"
}
