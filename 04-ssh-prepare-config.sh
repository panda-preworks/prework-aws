#!/bin/bash

mkdir -p ~/.ssh

aws ssm get-parameter \
    --name "/secrets/panda-workstation-key" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text > ~/.ssh/panda-workstation-ssh-key.pem

echo "YOUR SSH KEY IS:"
cat ~/.ssh/panda-workstation-ssh-key.pem

PANDA_PUBLIC_DNS_WORKSTATION=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=panda-workstation" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].PublicDnsName" \
    --output text)

echo $PANDA_PUBLIC_DNS_WORKSTATION

export SSH_CONFIG_TEMPLATE="Host aws-ec2
    HostName ${PANDA_PUBLIC_DNS_WORKSTATION}
    User ec2-user
    IdentityFile ~/.ssh/panda-workstation-ssh-key.pem"

echo "YOUR VS-CODE-SSH-CONFIG IS:"
echo "$SSH_CONFIG_TEMPLATE"
