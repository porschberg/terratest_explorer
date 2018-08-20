#!/usr/bin/env bash

set -e

AWS_PEM_PARAM_NAME="/terratest_explorer/test/terratest_key_pem"
AWS_PUB_PARAM_NAME="/terratest_explorer/test/terratest_key_pub_openssh"

script_dir=`dirname "$0"`
# goto dir of script
cd ${script_dir}

aws ssm get-parameter --name $AWS_PEM_PARAM_NAME --with-decryption --query Parameter.Value --output text > deploy_rsa.pem
aws ssm get-parameter --name $AWS_PUB_PARAM_NAME --with-decryption --query Parameter.Value --output text > deploy_rsa.pub

chmod 0600 deploy_rsa.pem

echo "SSH-Keys copied from AWS Paramater Store:  deploy_rsa.pem"
