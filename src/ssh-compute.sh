#!/usr/bin/env bash
set -e
set -e
script_dir=`dirname "$0"`
# goto dir of script
cd ${script_dir}

workspace=test

if [ -f "terraform/.terraform/environment" ]; then
  workspace=$(cat terraform/.terraform/environment)
fi

ssh -i ./deploy_rsa.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $1 ec2-user@${workspace}-2.terratestexplorer.beyondtouch.io -L 9080:localhost:9080
