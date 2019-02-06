variable "route53_beyondtouch_io_zoneid" {
  type    = "string"
  default = "Z97LVGVLPPV50"  # Zone-ID of beyondtouch.io in route53
}

locals {
  ec2_instance_types = {
    "ws1"   = "t2.micro"
    "ws2"   = "t2.small"
  }

  cert_vol_values = {
    "ws1"  = "vol-066537ace3c620d7e"
    "ws2"  = "vol-06d99e99d01427cd0"
  }

  ssh_privatefiles = {
    "ws1"  = "ws1_rsa.pem"
    "ws2"  = "ws1_rsa.pem"
  }

  ssh_pubfiles = {
    "ws1"  = "ws1_rsa.pub"
    "ws2"  = "ws2_rsa.pub"
  }

  ec2_instance_type = "${lookup(local.ec2_instance_types,terraform.workspace)}"

  key_file_pub = "../${lookup(local.ssh_pubfiles,terraform.workspace)}"
  key_file_private = "../${lookup(local.ssh_privatefiles,terraform.workspace)}"

  cert_vol_value = "${lookup(local.cert_vol_values,terraform.workspace)}"
}

