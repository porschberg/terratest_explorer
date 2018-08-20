terraform {
  backend "s3" {
    bucket         = "terraformworkspace-remote-state-storage-s3"
    key            = "crispytrain-backend-2"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}

provider "aws" {
  region = "eu-central-1"

  # AccesKey and secret must set in OS ENV!
}

resource "null_resource" "valid_workspace_check" {
  count = "${contains(var.valid_workspaces, terraform.workspace) ? 0 : 1}"

  # the output
  "ERROR: The selected workspace is invalid" = true
}
