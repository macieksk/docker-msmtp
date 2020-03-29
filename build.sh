#!/bin/bash
set -eux

VER="v$1"
DNAME="docker-msmtp"

docker build --progress plain -t "$DNAME":"$VER" .
docker tag "$DNAME":"$VER" "$DNAME":latest

#parallel -uj1 docker push ::: "$DNAME":"$VER" "$DNAME":latest

