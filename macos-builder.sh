#!/bin/bash

# this script will automatically build the latest versions of Node.js on macOS
# requires docker-machine, jq, xhyve and docker-machine-driver-xhyve
#
# brew install xhyve docker-machine-driver-xhyve
# sudo chown root:wheel /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
# sudo chmod u+s /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve 
#

base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine

cd $(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

HOST_CPU=$(sysctl -n hw.ncpu)
HOST_MEMORY=$(sysctl -n hw.memsize)

VM_NAME=node-builder
VM_CORES=$(($HOST_CPU / 2))
VM_MEMORY=$((($HOST_MEMORY / 1024 / 1024) / 2))

pkill -9 docker-machine-driver-xhyve
docker-machine rm -f $VM_NAME

set -e

docker-machine create \
  --driver xhyve \
  --xhyve-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v18.03.0-ce/boot2docker.iso \
  --xhyve-cpu-count $VM_CORES \
  --xhyve-memory-size $VM_MEMORY \
  --xhyve-disk-size 10000 \
  $VM_NAME

eval $(docker-machine env $VM_NAME)

docker-machine ssh $VM_NAME "sudo mkdir -p $(pwd)/out"

./build.sh $VM_NAME

docker-machine scp "$VM_NAME:$(pwd)/out/*" "$(pwd)/out/"

docker-machine rm -y $VM_NAME

