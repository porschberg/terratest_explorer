variable "route53_beyondtouch_io_zoneid" {
  type    = "string"
  default = "Z97LVGVLPPV50"  # Zone-ID of beyondtouch.io in route53
}

locals {
  ec2_instance_types = {
    "dev"  = "t2.micro"
    "prod" = "t2.small"
    "test"  = "t2.micro"
  }

  ec2_instance_type = "${lookup(local.ec2_instance_types,terraform.workspace)}"
}

