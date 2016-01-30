#!/bin/bash

# Script to install docker and cyber-dojo onto a raw Jessie (Debian 8) node.
# use curl to get this file, chmod +x it, then run it

branch=https://raw.githubusercontent.com/JonJagger/cyber-dojo/runner-auto-cache/docker

mkdir -p /var/www/cyber-dojo

curl -O ${branch}/debian_jessie/install_docker.sh
curl -O ${branch}/debian_jessie/docker-compose.debian_jessie.yml
curl -O ${branch}/debian_jessie/app_up.sh
curl -O ${branch}/docker-compose.yml

chmod +x install_docker.sh
./install_docker.sh

docker pull cyberdojofoundation/gcc_assert

chmod +x app_up.sh
./app_up.sh