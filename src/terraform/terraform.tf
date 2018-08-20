terraform {
  backend "s3" {
    bucket         = "terraformworkspace-remote-state-storage-s3"
    key            = "terratest_explorer"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}

provider "aws" {
  region = "eu-central-1"

  # AccesKey and secret must set in OS ENV!
}

