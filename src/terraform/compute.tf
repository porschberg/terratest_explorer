resource "aws_key_pair" "terratest_explorer_ssh" {
  key_name   = "terratest_explorer-${terraform.workspace}"
  public_key = "${file("${local.key_file_pub}")}"
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${local.cert_vol_value}"
  instance_id = "${aws_instance.terratest_explorer_compute.id}"
  skip_destroy = true
  force_detach = true
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/format_cert_volume.sh",
      "/home/ec2-user/format_cert_volume.sh",
    ]

    connection {
      host     = "${aws_instance.terratest_explorer_compute.public_ip}"
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${local.key_file_private}")}"
    }
  }
}

# security group for terratest_explorer backend 
resource "aws_security_group" "terratest_explorer_sec" {
  name        = "terratest_explorer_sec-${terraform.workspace}"
  description = "security group that allows inbound for web&ssh and outbound traffic from all instances in the VPC"

  #vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "terratest_explorer-access-${terraform.workspace}"
  }
}


resource "aws_instance" "terratest_explorer_compute" {
  ami                         = "${data.aws_ami.amazon_docker_img.id}"
  instance_type               = "${local.ec2_instance_type}"
  key_name                    = "${aws_key_pair.terratest_explorer_ssh.key_name}"
  associate_public_ip_address = true

  tags {
    Name = "TerratestExplorer-${terraform.workspace}"
  }

  provisioner "file" {
    source      = "format_cert_volume.sh"
    destination = "/home/ec2-user/format_cert_volume.sh"

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${local.key_file_private}")}"
    }
  }

  security_groups = ["default", "${aws_security_group.terratest_explorer_sec.name}"]
  user_data       = "${data.template_file.app_init_tpl.rendered}"
}


resource "aws_route53_record" "terratest_explorer_dns" {
  zone_id = "${var.route53_beyondtouch_io_zoneid}"    # Id der Zone "beyondtouch.io"
  name    = "${terraform.workspace}.terratestexplorer.beyondtouch.io"
  type    = "A"
  ttl     = "120"
  records = ["${aws_instance.terratest_explorer_compute.public_ip}"]
}

output "terratest_explorer_compute_public_ip" {
  value = "${aws_instance.terratest_explorer_compute.public_ip}"
}

output "terratest_explorer_compute_id" {
  value = "${aws_instance.terratest_explorer_compute.id}"
}
