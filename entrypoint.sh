#!/bin/bash
## Derived from https://hub.docker.com/r/philoles/ssmtp/ , 2020 
#
# Define environmental variables e.g.:
# TLS=on
# mailhub=smtp.gmail.com
# mailport=587
# user=xxxx@gmail.com

set -eu

## The password is taken from a first line from stdin.
## Subsequent lines are passed to msmtp.
mkfifo .mailfifo
cat | parallel --pipe -k -uj1 -N 1 --tmpdir /dev/shm \
        'if [ {#} -eq 1 ]; then cat > /root/.secret; \
         else cat; fi' > .mailfifo &
## It's verified there is no race condition for input with msmtp below

conf='/etc/msmtprc'
conf_custom='/etc/msmtprc_custom'
useTLS="${TLS:-on}"

[ ! "$mailhub" ] && echo 'mailhub is not set. eg: smtp.gmail.com' && exit 1
[ ! "$mailport" ] && echo 'mailport is not set. eg: 587' && exit 1
[ ! "$user" ] && echo 'user is not set. eg: xxxx@gmail.com' && exit 1
[ ! "$from" ] && echo 'from is not set. eg: xxxx@gmail.com' && exit 1
#[ ! $pass ] && echo 'pass is not set' && exit 1

sed -i "s|{{ mailhub }}|$mailhub|g; s|{{ mailport }}|$mailport|g; \
        s|{{ user }}|$user|g;       s|{{ useTLS }}|$useTLS|g; \
        s|{{ from }}|$from|g"  $conf_custom
#sed -i "s|{{ pass }}|$pass|g" $conf_custom

cp -f "$conf_custom" "$conf"
#cat $conf

cat .mailfifo | msmtp "$@"

rm /root/.secret
