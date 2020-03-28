#!/bin/bash
## Derived from https://hub.docker.com/r/philoles/ssmtp/ , 2020 
#
# e.g.
# TLS=YES
# mailhub=smtp.gmail.com:587
# AuthUser=xxxx@gmail.com
# AuthPass=xxx

conf='/etc/ssmtp/ssmtp.conf'
conf_custom='/etc/ssmtp/ssmtp_custom.conf'
UseTLS=${TLS:-'NO'}
UseSTARTTLS=${TLS:-'NO'}

[ ! $mailhub ] && echo 'mailhub is not set. eg: smtp.gmail.com:587' && exit 1
[ ! $AuthUser ] && echo 'AuthUser is not set. eg: xxxx@gmail.com' && exit 1
[ ! $AuthPass ] && echo 'AuthPass is not set' && exit 1

sed -i "s|{{ mailhub }}|$mailhub|g" $conf_custom
sed -i "s|{{ AuthUser }}|$AuthUser|g" $conf_custom
sed -i "s|{{ AuthPass }}|$AuthPass|g" $conf_custom
sed -i "s|{{ UseTLS }}|$UseTLS|g" $conf_custom
sed -i "s|{{ UseSTARTTLS }}|$UseSTARTTLS|g" $conf_custom

rm -f $conf
cp -f $conf_custom $conf

exec "$@"

