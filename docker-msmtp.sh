#!/bin/bash
set -eu #x

## Usage: { cat ~/.ssh/gmail_secret ; echo -e "Subject: msmtp test\nhello test." ; } | docker-msmtp.sh recipient@gmail.com
## These variables need to be defined:
#MAILHUB="smtp.gmail.com" 
#MAILPORT="587"
#TLS="on"
#USER="user@gmail.com"
#FROM="user@gmail.com"

DNAME="$(basename "$(mktemp -u -t 'msmtp_XXXXXXXX')")"
function oncancel {
    set -eux;
    docker stop "$DNAME" > /dev/null || true
    #docker rm "$DNAME" > /dev/null || true
    exit 1
}
trap oncancel SIGINT SIGTERM SIGKILL

PWDCMD="$1"
shift 1

{ eval "$PWDCMD" ; echo "__EMAILSTART__"; cat ; } \
| docker run --rm -i --name "$DNAME" \
      -e TLS="${TLS:-on}" -e mailhub="$MAILHUB" -e mailport="$MAILPORT" \
      -e user="$USER" -e from="$FROM" \
      docker-msmtp "$@" &
wait

