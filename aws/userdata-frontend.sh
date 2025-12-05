#!/bin/bash
set -e

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install CodeDeploy agent
yum install -y ruby wget
cd /home/ec2-user
wget https://aws-codedeploy-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Set environment variables
echo "export AWS_DEFAULT_REGION=${AWS_REGION}" >> /etc/environment
echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" >> /etc/environment
echo "export BACKEND_URL=${BACKEND_URL}" >> /etc/environment

# Start CodeDeploy agent
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

echo "Frontend EC2 instance setup complete"
