#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

exec > >(tee /var/log/jenkins-controller-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y

apt-get install -y \
  openjdk-21-jdk \
  fontconfig \
  git \
  curl \
  wget \
  unzip \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  docker.io

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu || true

# AWS CLI v2
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
rm -rf /tmp/aws
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update

# Terraform official repository
mkdir -p /etc/apt/keyrings
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list

# Jenkins LTS official repository
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

apt-get update -y
apt-get install -y terraform jenkins

# Allow Jenkins to run Docker commands
usermod -aG docker jenkins || true

# Ensure Java 21 is default
update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac

systemctl enable jenkins
systemctl restart jenkins

java -version
git --version
docker --version
/usr/local/bin/aws --version
terraform version
systemctl status jenkins --no-pager || true