#!/bin/bash
set -ex

# Update packages and install dependencies
sudo yum update -y
sudo yum install -y git
sudo amazon-linux-extras install docker -y

# Start and enable Docker
sudo service docker start
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Clone your app repository
cd /home/ec2-user
git clone https://github.com/H-raheel/reactapp.git
cd reactapp

# Ensure Dockerfile and nginx.conf exist
# If not already inside repo, add them via scripts or provisioning tools

# Build and run Docker container
sudo docker build -t react-app .
sudo docker run -d \
  --name react-container \
  -p 8080:8080 \
  react-app
