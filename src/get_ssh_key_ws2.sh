#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
# goto dir of script
cd ${script_dir}


AWS_PEM_PARAM_NAME="/terratest_explorer/ws1/ssh_key_pem"
AWS_PUB_PARAM_NAME="/terratest_explorer/ws1/ssh_key_pub"


aws ssm get-parameter --name $AWS_PEM_PARAM_NAME --with-decryption --query Parameter.Value --output text > ws1_rsa.pem
aws ssm get-parameter --name $AWS_PUB_PARAM_NAME --with-decryption --query Parameter.Value --output text > ws1_rsa.pub


chmod 0600 deploy_rsa.pem

echo "SSH-Keys copied from AWS Paramater Store:  ws1_rsa.pem / ws1_rsa.pub"
