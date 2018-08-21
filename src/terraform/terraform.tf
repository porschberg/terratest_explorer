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
  version = "~> 1.32"
}

provider "template" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.2"
}
