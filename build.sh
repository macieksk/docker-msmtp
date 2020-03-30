#!/bin/bash
set -eux

VER="v$1"
DNAME="docker-msmtp"

docker build --progress plain -t "$DNAME":"$VER" .
docker tag "$DNAME":"$VER" "$DNAME":latest

set +u
if [ "x$2" = "x-p" ]; then
set -u
DUSER="macieksk"
docker tag "$DNAME":"$VER" "$DUSER/$DNAME":"$VER"
docker tag "$DNAME":latest "$DUSER/$DNAME":latest
parallel -uj1 docker push ::: "$DUSER/$DNAME":"$VER" "$DUSER/$DNAME":latest
fi

