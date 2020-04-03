#!/bin/bash
set -eux

VER="$( sed -e 's/^VER="\([^"]*\)".*$/\1/;t;d' docker-msmtp.sh)"
DNAME="docker-msmtp"
DUSER="macieksk"

docker build --progress plain -t "$DNAME":"$VER" .
docker tag "$DNAME":"$VER" "$DNAME":latest

set +u
if [ "x$1" = "x-p" ]; then
set -u
docker tag "$DNAME":"$VER" "$DUSER/$DNAME":"$VER"
docker tag "$DNAME":latest "$DUSER/$DNAME":latest
parallel -uj1 docker push ::: "$DUSER/$DNAME":"$VER" "$DUSER/$DNAME":latest
fi

