#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

exec > >(tee /var/log/jenkins-agent-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

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

apt-get update -y
apt-get install -y terraform

# Ensure Java 21 is default for Jenkins agent remoting
update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac

java -version
git --version
docker --version
/usr/local/bin/aws --version
terraform version