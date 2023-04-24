terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Saving state on S3 Remote state.
  backend "s3" {
    # What is your bucket name to save to save the terraform state
    bucket                  = "BUCKET_NAME"

    key                     = "common/terraform.state"

    # Name of your profile (You can skip the profile name if using with ec2 instance profile)
    profile                 = "PROFILE_NAME"

    # Region. For example is region singapore.
    region                  = "ap-southeast-1"
  }

}

provider "aws" {

  # Name of your profile (You can skip the profile name if using with ec2 instance profile)
  profile = "PROFILE_NAME"

  # Region. For example is region singapore.
  region  = "ap-southeast-1"
}
