#!/bin/bash

set -ex

# Update all packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker and AWS CLI
sudo apt-get install docker.io awscli -y

systemctl enable docker
systemctl start docker

# Creating a dedicated docker network for services and postgres
sudo docker network create 1to100 || true       # if already created, leave it

# Run service B
sudo docker run -d -p 9001:9001 --name service-b --network 1to100 --restart always -e DB_HOST=${db_host} ${service_b_imageurl}

# Run service A
sudo docker run -d -p 9000:9000 --name service-a --network 1to100 --restart always -e DB_HOST=${db_host} -e SERVICE_B_URI=http://service-b:9001/hello ${service_a_imageurl}