#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

exec > >(tee /var/log/bluegreen-app-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y
apt-get install -y docker.io awscli

systemctl enable docker
systemctl start docker

aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin ${ecr_registry}

docker rm -f attendance-app || true

docker run -d \
  --name attendance-app \
  --restart unless-stopped \
  -p 3000:3000 \
  -e COLOR=${color} \
  ${image_uri}

docker ps