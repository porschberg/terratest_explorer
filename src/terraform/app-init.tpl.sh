#!/bin/env bash
# Script to run as cloud init after create a VM
# customized for AWS Docker-AMI

set -e

# Install Docker-Compose
yum install -y -q wget
wget -q -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.20.1/docker-compose-Linux-x86_64
chmod +x /usr/local/bin/docker-compose

mkdir /home/ec2-user/documentation
cd /home/ec2-user/documentation

# Create docker-compose-yml
cat << EOS > docker-compose.yml
version: '3'
services:
  backend:
    restart: unless-stopped
    image: pierrezemb/gostatic
    volumes:
      - "data:/srv/http"
    ports:
      - "80:8043"
    environment:
      CRISPYTRAIN_STAGE: ${crispy_stage}
    labels:
      - "traefik.enable=true"
      - "traefik.documentation=http"
      - "traefik.port=8043"
      - "traefik.frontend.rule=Host:${crispy_stage}-documentation.crispytrain.beyondtouch.io"
      - "traefik.frontend.entryPoints=http,https"
      - "traefik.documentation=documentation"
      #- "traefik.docker.network=traefik_public"
  traefik:
    image: beyondtouch/traefik-proxy
    ports:
      - "80:80"
      - "443:443"
      - "9080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped

volumes:
  data:
EOS

# Pull Docker-Images and Start the Docker-Containers
sudo -u ec2-user docker login -u beyondtouchdeployer -p '${beyondtouchdeployer_pwd}'
sudo -u ec2-user /usr/local/bin/docker-compose pull
sudo -u ec2-user /usr/local/bin/docker-compose up -d
