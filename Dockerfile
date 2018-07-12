ARG BASE_IMAGE
FROM ${BASE_IMAGE:-library/alpine}:3.7

ARG QEMU_ARCH
ENV QEMU_ARCH=${QEMU_ARCH:-x86_64}

COPY qemu/qemu-${QEMU_ARCH}-static /usr/bin/

CMD mkdir /dest \
    && rm -rf /dest/usr \
    && addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        binutils-gold \
        curl \
        g++ \
        gcc \
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
  # gpg keys listed at https://github.com/nodejs/node#release-team
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
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
