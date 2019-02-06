#!/usr/bin/env bash
set -e
set -e
script_dir=`dirname "$0"`
# goto dir of script
cd ${script_dir}

workspace=ws1

ssh -i ./ws1_rsa.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $1 ec2-user@${workspace}.terratestexplorer.beyondtouch.io -L 9080:localhost:9080

