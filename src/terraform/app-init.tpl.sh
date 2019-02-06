#!/bin/env bash
# Script to run as cloud init after create a VM
# customized for AWS Docker-AMI

set -e

# Install Docker-Compose
yum install -y -q wget
wget -q -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.20.1/docker-compose-Linux-x86_64
chmod +x /usr/local/bin/docker-compose

# create public network
docker network create public

mkdir -p /home/ec2-user/web/data
cd /home/ec2-user/web

# Create .env for docker-compose
cat << EOS > .env
terratest_explorer_stage=${terratest_explorer_stage}
EOS

# Create docker-compose-yml
echo '${docker_compose}' > ./docker-compose.yml

# Create initial content
echo '${index_content}' > ./data/index.html

# Create traefik config
echo '${traefik_config}' > ./traefik.toml

chown ec2-user * .env

# Pull Docker-Images and Start the Docker-Containers
sudo -u ec2-user /usr/local/bin/docker-compose pull
sudo -u ec2-user /usr/local/bin/docker-compose up -d
