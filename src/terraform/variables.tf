variable "valid_workspaces" {
  description = "A list of valid workspaces to deploy to"
  default     = ["prod", "dev", "test"]
  type        = "list"
}

locals {
  ec2_instance_types = {
    "dev"  = "t2.medium"
    "prod" = "t2.medium"
    "test"  = "t2.medium"
  }

  ec2_instance_type           = "${lookup(local.ec2_instance_types,terraform.workspace)}"

  frontend_fqdn = "crsipy-train-${terraform.workspace}.beyondtouch.io"
}

variable "key_file_pub" {
  type    = "string"
  default = "../docker-crispy.pub"
}

variable "key_file_private" {
  type    = "string"
  default = "../docker-crispy"
}

variable "route53_beyondtouch_io_zoneid" {
  type    = "string"
  default = "Z97LVGVLPPV50"  # Zone-ID of beyondtouch.io in route53
}

variable alias_zone_id {
  description = "Fixed hardcoded constant zone_id that is used for all CloudFront distributions"
  default = "Z2FDTNDATAQYW2"
}
