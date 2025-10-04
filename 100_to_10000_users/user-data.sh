#!/bin/bash

set -ex

until ping -c1 8.8.8.8 &>/dev/null; do sleep 5; done

# Update all packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker and AWS CLI
sudo apt-get install docker.io awscli -y

systemctl enable docker
systemctl start docker

# Creating a dedicated docker network for services and postgres
docker network create 1to100 || true       # if already created, leave it

# --- Run Service B, connecting to RDS ---
docker run -d --name service-b --network 1to100 \
  -e DB_HOST=${db_host} \
  -e DB_USER=${db_user} \
  -e DB_PASSWORD=${db_pass} \
  -e DB_NAME=${db_name} \
  -e DB_PORT=5432 \
  ${service_b_imageurl}

# --- Run Service A, connecting to RDS ---
docker run -d -p 9000:9000 --name service-a --network 1to100 \
  -e SERVICE_B_URI="http://service-b:9001" \
  -e DB_HOST=${db_host} \
  -e DB_USER=${db_user} \
  -e DB_PASSWORD=${db_pass} \
  -e DB_NAME=${db_name} \
  -e DB_PORT=5432 \
  ${service_a_imageurl}