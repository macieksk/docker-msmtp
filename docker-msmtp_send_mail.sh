#!/bin/bash
set -eu -o pipefail

#MSGTYPE="${MSGTYPE:-l}" ## m for text, l for html
MSGTYPE="${MSGTYPE:-m}"
YAMLCONF="${YAMLCONF:-$HOME/.mailconf.yaml}"

TO="$1"     ## "address@email.com, address2@email2.com"
SUBJECT="$2"
shift 2
set +u
if [ -n "$1" ]; then ATTACHMENTSDIR="$1"; shift 1;
else ATTACHMENTSDIR=""; fi
set -u

SCRIPTDIR="$(dirname "$(realpath "$0")")"
source "$SCRIPTDIR/yaml.sh"
create_variables "$YAMLCONF" "conf_"

export TO
set -x
export MAILHUB="${conf_MAILHUB[0]}" #="smtp.gmail.com" 
export MAILPORT="${conf_MAILPORT[0]}" #="587"
export TLS="${conf_TLS[0]}" #="on"
export USER="${conf_USER[0]}" #="user@gmail.com"
export FROM="${conf_FROM[0]}" #="user@gmail.com" 
export PWDCMD="${conf_PWDCMD[0]}"
#export PWDCMD="gpg --decrypt ~/.ssh/gmail_secret.gpg"
#export PWDCMD="cat ~/.ssh/gmail_secret"
#export PWDCMD="echo"
set +x

#echo -e "From: $FROM\nTo: $TO\nSubject: $SUBJECT\n\n$(cat)" \
"$SCRIPTDIR"/compose-mail.py -f "$FROM" -r "$TO" -s "$SUBJECT" -d "$ATTACHMENTSDIR" -"$MSGTYPE" - \
 | "$SCRIPTDIR"/docker-msmtp.sh -t "$TO" "$@"

#export PWDCMD="echo"
#echo | ./docker-msmtp.sh -P "$@"
