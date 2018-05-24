# Node.js Build for Alpine Linux

The purpose of this repo is to build Node.js for Alpine Linux on amd64, arm32v6 and arm64v8.

Builds can be found under [releases](https://github.com/oznu/alpine-node/releases).

Install:

```shell
# Install deps
apk add --no-cache libgcc libstdc++ curl

# Download pre-built binary
curl -fLO https://github.com/oznu/alpine-node/releases/download/8.11.2/node-v8.11.2-linux-x86_64-alpine.tar.gz

# Extract / install
tar -xzf node-v8.11.2-linux-x86_64-alpine.tar.gz -C /usr --strip-components=1 --no-same-owner

# Clean Up
rm -rf node-v8.11.2-linux-x86_64-alpine.tar.gz
```
