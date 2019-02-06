data "aws_availability_zones" "available" {}

resource "aws_ebs_volume" "certificate_volume" {
  availability_zone = "eu-central-1b"
  size              = 1
  tags = {
    Name   = "${terraform.workspace}_aws_ebs_volume_certificate_volume"
    Stage  = "${terraform.workspace}"
    Description = "This volume is used to store the Lets Encrypt certificate on a durable storage that survives destroying the ecs2-instance. Otherwise can run into https://letsencrypt.org/docs/rate-limits/"
  }
}

output "certificate_volume" {
  value = "${aws_ebs_volume.certificate_volume.id}"
}


