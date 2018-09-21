#!/bin/bash

[[ -f /home/james/.credentials ]] \
        && . /home/james/.credentials \
        || { echo "Credentials not found"; exit 1; }


DUCK_UPDATE_URL="https://www.duckdns.org/update?domains"
DUCK_LOG="/var/log/duckdns/duck.log"


echo url="$DUCK_UPDATE_URL=$DUCK_DOMAIN&token=$DUCK_TOKEN&ip=" | curl -k -o $DUCK_LOG -K -
