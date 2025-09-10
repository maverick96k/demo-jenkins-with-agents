#!/bin/bash
#========================================================
# Script Name: install-upgrade-agent-java-docker.sh
# Author     : Akshay Kurade
# Description: Update system packages, install/upgrade
#              OpenJDK 21, Docker, AWS CLI v2, and Trivy
#              on a Jenkins agent node.
#========================================================

set -euo pipefail
IFS=$'\n\t'

echo "========== Updating system packages =========="
sudo apt-get update -y
sudo apt-get upgrade -y

#--------------------------------------------------------
# Java Installation
#--------------------------------------------------------
echo "========== Installing/Upgrading Java (OpenJDK 21) =========="
sudo apt-get install -y openjdk-21-jre fontconfig

# Verify Java installation
echo "========== Verifying Java version =========="
java -version

#--------------------------------------------------------
# Docker Installation
#--------------------------------------------------------
echo "========== Installing Docker (docker.io) =========="
sudo apt-get install -y docker.io

echo "========== Enabling & Starting Docker service =========="
sudo systemctl enable docker
sudo systemctl start docker

echo "========== Adding user to docker group =========="
sudo usermod -aG docker "$USER"


#--------------------------------------------------------
# AWS CLI v2 Installation
#--------------------------------------------------------
echo "========== Installing AWS CLI v2 =========="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install -y unzip
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
aws --version

#--------------------------------------------------------
# Trivy Installation
#--------------------------------------------------------
echo "========== Installing Trivy =========="
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | \
  sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy
trivy --version

#---------
