#!/bin/bash

cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

cat trust-policy.json

aws iam create-role --role-name PandaEC2AdminRole --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy --role-name PandaEC2AdminRole --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

aws iam create-instance-profile --instance-profile-name PandaEC2AdminInstanceProfile

aws iam add-role-to-instance-profile --instance-profile-name PandaEC2AdminInstanceProfile --role-name PandaEC2AdminRole
