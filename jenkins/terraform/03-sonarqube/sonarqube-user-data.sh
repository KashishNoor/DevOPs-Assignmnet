#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

exec > >(tee /var/log/sonarqube-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y

apt-get install -y \
  docker.io \
  curl \
  unzip \
  ca-certificates \
  gnupg \
  lsb-release

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu || true

# Add swap so SonarQube has enough breathing room on smaller instances.
fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab

sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

docker pull sonarqube:lts-community

docker run -d \
  --name sonarqube \
  --restart unless-stopped \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -e SONAR_WEB_JAVAOPTS="-Xmx512m -Xms256m" \
  -e SONAR_CE_JAVAOPTS="-Xmx512m -Xms256m" \
  -e SONAR_SEARCH_JAVAOPTS="-Xmx512m -Xms512m" \
  sonarqube:lts-community

docker ps
