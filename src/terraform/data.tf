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
