#!/bin/env bash

echo "Start $0"

#this external volume is needed for storage of the traefik-letsencryp-certificates

if [[ `sudo blkid -o value -s TYPE /dev/sdh` = "ext4" ]]
then
  echo "/dev/sdh has already ext4 filesystem..."
else
  echo "We have still a raw volume..."
  echo "Let us create a ext4 filesystem on it. We will use this volume to store traefik certificates..."
  sudo mkfs -t ext4 /dev/sdh
fi

sudo su -c "echo '/dev/sdh /certs ext4 defaults,nofail' >> /etc/fstab"
sudo mkdir -p /certs
sudo mount /dev/sdh /certs
