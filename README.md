# Node.js Build for Alpine Linux

The purpose of this repo is to build Node.js for Alpine Linux on amd64, arm32v6 and arm64v8.

Builds can be found under [releases](https://github.com/oznu/alpine-node/releases).

Install:

```
apk add --no-cache libgcc libstdc++

tar -xzf node-v8.11.2-linux-x86_64-alpine.tar.gz -C /usr --strip-components=1 --no-same-owner
```
