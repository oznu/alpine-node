#!/bin/bash

# this script will automatically build the latest versions of Node.js on macOS
# requires docker-machine, virtualbox and jq to be installed

cd $(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

osascript -e 'display notification "Node.js build started" with title "oznu/alpine-node"'

HOST_CPU=$(sysctl -n hw.ncpu)
HOST_MEMORY=$(sysctl -n hw.memsize)

VM_NAME=node-builder
VM_CORES=$(($HOST_CPU / 2))
VM_MEMORY=$((($HOST_MEMORY / 1024 / 1024) / 2))

docker-machine create \
  --driver "virtualbox" \
  --virtualbox-memory $VM_MEMORY \
  --virtualbox-cpu-count $VM_CORES \
  --virtualbox-disk-size 10000 \
  --virtualbox-ui-type headless \
  --virtualbox-share-folder "$(pwd)/out:$(pwd)/out" \
  $VM_NAME

eval $(docker-machine env $VM_NAME)

./build.sh

docker-machine rm -y $VM_NAME

osascript -e 'display notification "Node.js build finished" with title "oznu/alpine-node"'
