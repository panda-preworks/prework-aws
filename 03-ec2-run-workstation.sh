#!/bin/bash

AMI_ID=$(aws ec2 describe-images --region us-east-1 --filters "Name=name,Values=amzn2-ami-kernel-*-x86_64-gp2" "Name=state,Values=available" --query "Images | sort_by(@, &CreationDate)[-1].ImageId" --output text)
echo $AMI_ID

SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --description "SG for Panda WorkStation" \
    --group-name  "panda-workstation-sg" \
    --region "us-east-1" \
    --output text --query 'GroupId')

echo $SECURITY_GROUP_ID

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp --port 22 --cidr 0.0.0.0/0 \
    --region "us-east-1"

aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name panda-workstation-key \
    --security-group-ids $SECURITY_GROUP_ID \
    --iam-instance-profile Name=PandaEC2AdminInstanceProfile \
    --user-data '#!/bin/bash
set -ex
exec > >(tee /var/log/userdata.log|logger -t userdata)
yum update -y
yum install -y yum-utils
yum install -y git
yum install -y unzip
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform
curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs' \
    --region us-east-1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=panda-workstation}]'
