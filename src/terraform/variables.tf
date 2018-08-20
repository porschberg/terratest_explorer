
locals {
  ec2_instance_types = {
    "dev"  = "t2.micro"
    "prod" = "t2.small"
    "test"  = "t2.micro"
  }

  ec2_instance_type           = "${lookup(local.ec2_instance_types,terraform.workspace)}"
}

variable "key_file_pub" {
  type    = "string"
  default = "../deploy_rsa.pub"
}

variable "key_file_private" {
  type    = "string"
  default = "../deploy_rsa.pem"
}

variable "route53_beyondtouch_io_zoneid" {
  type    = "string"
  default = "Z97LVGVLPPV50"  # Zone-ID of beyondtouch.io in route53
}
