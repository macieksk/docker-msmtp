#!/bin/bash
set -eu
#SERVER="smtp.gmail.com:587"
SERVER="$1"
printf 'quit\n' | openssl s_client -connect "$SERVER" | grep 'Verify return code: 0 (ok)'
