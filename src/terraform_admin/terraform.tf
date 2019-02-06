terraform {
  backend "s3" {
    bucket         = "terraformworkspace-remote-state-storage-s3"
    key            = "terratest_explorer_admin"
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

variable "valid_workspaces" {
  description = "A list of valid workspaces to deploy to"
  default     = ["ws1", "ws2"]
  type        = "list"
}

resource "null_resource" "valid_workspace_check" {
  count = "${contains(var.valid_workspaces, terraform.workspace) ? 0 : 1}"

  # the output
  "ERROR: The selected workspace '${terraform.workspace}' is invalid!" = true
}
