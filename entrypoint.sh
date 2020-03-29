#!/bin/bash
## Derived from https://hub.docker.com/r/philoles/ssmtp/ , 2020 
#
# Define environmental variables e.g.:
# TLS=on
# mailhub=smtp.gmail.com
# mailport=587
# user=xxxx  # often xxxx@gmail.com
# from=xxxx@gmail.com

set -eu

## The password is taken from a first line from stdin.
## Subsequent lines are passed to msmtp.
mkfifo --mode=600 .mailfifo
mkfifo --mode=600 /root/.secret
cat | parallel --pipe -u -N 1 --tmpdir /dev/shm \
        --recend '__EMAILSTART__\n' --removerecsep \
        'if [ {#} -eq 1 ]; then sponge > /root/.secret; \
         else cat > .mailfifo; fi' &
## It's been verified there is no race condition for input with msmtp below

conf='/etc/msmtprc'
conf_custom='/etc/msmtprc_custom'
useTLS="${TLS:-on}"

[ ! "$mailhub" ] && echo 'mailhub is not set. eg: smtp.gmail.com' && exit 1
[ ! "$mailport" ] && echo 'mailport is not set. eg: 587' && exit 1
[ ! "$user" ] && echo 'user is not set. eg: xxxx@gmail.com' && exit 1
[ ! "$from" ] && echo 'from is not set. eg: xxxx@gmail.com' && exit 1
#[ ! $pass ] && echo 'pass is not set' && exit 1

< "$conf_custom" \
  sed "s|{{ mailhub }}|$mailhub|g; s|{{ mailport }}|$mailport|g; \
        s|{{ user }}|$user|g;       s|{{ useTLS }}|$useTLS|g; \
        s|{{ from }}|$from|g" \
  > "$conf" 
#cat "$conf"

LOG="/dev/shm/msmtp.log"

< .mailfifo msmtp -X "$LOG" "$@" &
PID="$!"
##Make sure logs are output
tail -F "$LOG" --pid="$PID" 2>/dev/null

wait "$PID" 

