#!/bin/bash
set -eu #x

## Usage: echo -e "Subject: msmtp test\nhello test." | docker-msmtp.sh recipient@gmail.com
## These environment variables need to be defined:
#MAILHUB="smtp.gmail.com" 
#MAILPORT="587"
#TLS="on"
#USER="user@gmail.com"
#FROM="user@gmail.com"
#PWDCMD="gpg --decrypt ~/.ssh/gmail_secret.gpg"
#PWDCMD="cat ~/.ssh/gmail_secret"

DOCKERUSER="macieksk/" ## Obligatory /
#DOCKERUSER="" ## Leave empty for own build

DNAME="$(basename "$(mktemp -u -t 'msmtp_XXXXXXXX')")"
function oncancel {
    set -eux;
    docker stop "$DNAME" > /dev/null || true
    #docker rm "$DNAME" > /dev/null || true
    exit 1
}
trap oncancel SIGINT SIGTERM SIGKILL

{ eval "$PWDCMD" ; echo "__EMAILSTART__"; cat ; } \
| docker run --rm -i --name "$DNAME" \
      -e TLS="${TLS:-on}" -e mailhub="$MAILHUB" -e mailport="$MAILPORT" \
      -e user="$USER" -e from="$FROM" \
      "$DOCKERUSER"docker-msmtp "$@" &
wait

