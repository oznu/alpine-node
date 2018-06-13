#!/bin/sh

TAG=$1
NAME=$2
REPO="oznu/alpine-node"

# check tag does not already
if curl -sfn "https://api.github.com/repos/$REPO/releases/tags/$TAG" > /dev/null; then
    echo "Release For $NAME Already Exists"
    exit 0
else
    echo "Release For $NAME Not Found"
fi

# build release payload
RELEASE_PAYLOAD=$(jq --null-input \
    --arg tag "$TAG" \
    --arg name "$NAME" \
    --arg body "" \
    '{ tag_name: $tag, name: $name, body: $body, draft: false }')

# create release
RELEASE=$(curl -fsLn --data "$RELEASE_PAYLOAD" "https://api.github.com/repos/${REPO}/releases")

# extract upload url
UPLOAD_URL="$(echo "$RELEASE" | jq -r .upload_url | sed -e "s/{?name,label}//")"

# upload binaries
for FILE in out/node-v$TAG-linux-*-alpine.tar.gz; do
  echo "Uploading $FILE..."
  curl -n# -H "Content-Type: application/octet-stream" --data-binary "@$FILE" "$UPLOAD_URL?name=$(basename "$FILE")" > /dev/null
done
