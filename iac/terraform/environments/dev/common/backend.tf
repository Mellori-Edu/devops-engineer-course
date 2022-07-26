terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    bucket = ""
    key    = ""
    region = ""
    profile = ""
    shared_credentials_file = "~/.aws/credentials"
    skip_metadata_api_check = true
  }
}
