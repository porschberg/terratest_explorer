resource "aws_key_pair" "terratest_explorer_ssh" {
  key_name   = "terratest_explorer-${terraform.workspace}"
  public_key = "${tls_private_key.terratest_key.public_key_openssh}"
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

data "aws_ami" "amazon_docker_img" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # Amazon
}


# Template for shell-script with install docker-compose, create docker-compose.yml, 
# pull images and up the containers
data "template_file" "app_init_tpl" {
  template = "${file("app-init.tpl.sh")}"

  vars {
    terratest_explorer_stage = "${terraform.workspace}"
    docker_compose           = "${file("docker-compose.yml")}"
    index_content            = "${file("index.html")}"
    traefik_config           = "${file("traefik.toml")}"
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

  security_groups = ["default", "${aws_security_group.terratest_explorer_sec.name}"]
  user_data       = "${data.template_file.app_init_tpl.rendered}"
}


resource "aws_route53_record" "terratest_explorer_dns" {
  zone_id = "Z97LVGVLPPV50"                                             # Id der Zone "beyondtouch.io"
  name    = "${terraform.workspace}.terratestexplorer.beyondtouch.io"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.terratest_explorer_compute.public_ip}"]
}

output "terratest_explorer_compute_public_ip" {
  value = "${aws_instance.terratest_explorer_compute.public_ip}"
}

output "terratest_explorer_compute_id" {
  value = "${aws_instance.terratest_explorer_compute.id}"
}
