resource "aws_key_pair" "crispy_train_ssh" {
  key_name   = "crispy-train-${terraform.workspace}"
  public_key = "${file(var.key_file_pub)}"
}

# security group for crispytrain backend 
resource "aws_security_group" "crispy_sec_documentation" {
  name        = "crispy_sec_documentation-${terraform.workspace}"
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
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "crispy-access-${terraform.workspace}"
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

data "aws_ssm_parameter" "beyondtouchdeployer_pwd" {
  name  = "/crispytrain/beyondtouchdeployer_pwd"
  with_decryption = true
}

# Template for shell-script with install docker-compose, create docker-compose.yml, 
# pull images and up the containers
data "template_file" "app_init_tpl" {
  template = "${file("app-init.tpl.sh")}"

  vars {
    crispy_stage = "${terraform.workspace}"
    beyondtouchdeployer_pwd = "${data.aws_ssm_parameter.beyondtouchdeployer_pwd.value}"
  }
}

resource "aws_instance" "documentation_compute" {
  ami                         = "${data.aws_ami.amazon_docker_img.id}"
  instance_type               = "${local.ec2_instance_type}"
  key_name                    = "${aws_key_pair.crispy_train_ssh.key_name}"
  associate_public_ip_address = true
  iam_instance_profile        = "crispy_ro_profile-${terraform.workspace}"

  tags {
    Name = "CrispytrainDocumentation-${terraform.workspace}"
  }

  security_groups = ["default", "${aws_security_group.crispy_sec_documentation.name}"]
  user_data       = "${data.template_file.app_init_tpl.rendered}"
}


resource "aws_route53_record" "documentation_dns" {
  zone_id = "Z97LVGVLPPV50"                                             # Id der Zone "beyondtouch.io"
  name    = "${terraform.workspace}-documentation.crispytrain.beyondtouch.io"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.documentation_compute.public_ip}"]
}

output "documentation_compute_public_ip" {
  value = "${aws_instance.documentation_compute.public_ip}"
}

output "documentation_compute_id" {
  value = "${aws_instance.documentation_compute.id}"
}
