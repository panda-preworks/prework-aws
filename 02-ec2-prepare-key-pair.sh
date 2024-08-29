#!/bin/bash

aws ssm put-parameter \
    --name "/secrets/panda-workstation-key" \
    --value "$(aws ec2 create-key-pair --key-name panda-workstation-key --query 'KeyMaterial' --output text)" \
    --type "SecureString" \
    --overwrite
