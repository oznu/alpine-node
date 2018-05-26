#!/bin/sh

set -e

docker run --rm --privileged multiarch/qemu-user-static:register --reset

LTS=8.11.2
LATEST=10.2.1

mkdir -p out

for NODE_VERSION in $LTS $LATEST; do
    for QEMU_ARCH in x86_64 aarch64 arm; do
        if [ -f "out/node-v$NODE_VERSION-linux-$QEMU_ARCH-alpine.tar.gz" ]; then
            echo "node-v$NODE_VERSION-linux-$QEMU_ARCH-alpine already compiled"
        else
            case "$QEMU_ARCH" in \
            x86_64) BASE_IMAGE='library/alpine';; \
            arm) BASE_IMAGE='arm32v6/alpine';; \
            aarch64) BASE_IMAGE='arm64v8/alpine';; \
            *) echo "unsupported architecture"; exit 1 ;; \
            esac \
            && echo "Building node $NODE_VERSION for $QEMU_ARCH using $BASE_IMAGE" \
            && docker build --build-arg BASE_IMAGE=$BASE_IMAGE --build-arg QEMU_ARCH=$QEMU_ARCH -t node-$QEMU_ARCH . \
            && docker run --rm -e NODE_VERSION=$NODE_VERSION -v $(pwd)/out:/dest node-$QEMU_ARCH
        fi
    done
done

