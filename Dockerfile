ARG BASE_IMAGE
FROM ${BASE_IMAGE:-library/alpine}:3.10

ARG QEMU_ARCH
ENV QEMU_ARCH=${QEMU_ARCH:-x86_64}

COPY qemu/qemu-${QEMU_ARCH}-static /usr/bin/

CMD mkdir /dest \
    && rm -rf /dest/usr \
    && addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk upgrade \
    && apk add --no-cache --virtual .build-deps \
        binutils-gold \
        curl \
        g++ \
        gcc \
        git \
        bash \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python \
        paxmark \
        ca-certificates \
        openssl-dev \
        zlib-dev \
        libuv \
        libuv-dev \
        openssl-dev \
        http-parser-dev \
        c-ares-dev \
    && git clone https://github.com/canterberry/nodejs-keys.git \
    && nodejs-keys/cli.sh import \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure --prefix=/usr/local \
    && make -j$(getconf _NPROCESSORS_ONLN) -C out mksnapshot BUILDTYPE=Release \
    && paxmark -m out/Release/mksnapshot \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && paxmark -m out/Release/node \
    && make DESTDIR=/dest install \
    && paxmark -m /dest/usr/local/bin/node \
    && cd /dest \
    && tar -C /dest/usr -zcvf "node-v$NODE_VERSION-linux-${QEMU_ARCH:-x86_64}-alpine.tar.gz" . \
    && cp "node-v$NODE_VERSION-linux-${QEMU_ARCH:-x86_64}-alpine.tar.gz" /out/
