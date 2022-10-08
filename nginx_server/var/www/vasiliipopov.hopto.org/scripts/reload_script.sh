#!/bin/bash

while true
do
    count=$(ps aux | grep 'controlling_nginx_logs.sh' | awk 'END{print FNR}')

    if [[ "$count" -lt 2 ]]; then
        start-stop-daemon --user 0 --exec /var/www/vasiliipopov.hopto.org/scripts/controlling_nginx_logs.sh --start --background
    fi

    sleep 5

done