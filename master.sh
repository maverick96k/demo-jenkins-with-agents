#!/bin/bash
#========================================================
# Script Name: install-jenkins.sh
# Author     : Akshay Kurade
# Description: Install OpenJDK 21, Jenkins, AWS CLI v2,
#              kubectl (latest), eksctl, Docker, and SonarQube.
#========================================================

set -euo pipefail
IFS=$'\n\t'

echo "========== Updating system packages =========="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "========== Installing Java (OpenJDK 21) & dependencies =========="
sudo apt-get install -y openjdk-21-jre fontconfig wget gnupg curl unzip apt-transport-https ca-certificates software-properties-common lsb-release

#--------------------------------------------------------
# Jenkins Installation
#--------------------------------------------------------
echo "========== Adding Jenkins repository key =========="
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "========== Adding Jenkins repository =========="
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "========== Updating package list =========="
sudo apt-get update -y

echo "========== Installing Jenkins =========="
sudo apt-get install -y jenkins

echo "========== Enabling and starting Jenkins service =========="
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager

#--------------------------------------------------------
# AWS CLI v2 Installation
#--------------------------------------------------------
echo "========== Installing AWS CLI v2 =========="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws
aws --version

# Set default AWS region
echo "========== Configuring AWS Region (eu-north-1) =========="
mkdir -p ~/.aws
cat > ~/.aws/config <<EOL
[default]
region = eu-north-1
output = json
EOL

#--------------------------------------------------------
# kubectl Installation (Latest Stable)
#--------------------------------------------------------
echo "========== Installing kubectl (latest stable) =========="
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
# verify installation
kubectl version --client=true

#--------------------------------------------------------
# eksctl Installation
#--------------------------------------------------------
echo "========== Installing eksctl =========="
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

#--------------------------------------------------------
# Docker & SonarQube Installation
#--------------------------------------------------------
echo "========== Installing Docker =========="
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER

echo "========== Running SonarQube (LTS Community) =========="
docker run -itd --name SonarQube-Server -p 9000:9000 sonarqube:lts

echo "========== Installation Completed =========="
