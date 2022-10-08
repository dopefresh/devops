#!/bin/bash

last_line_4xx_response_saved_log=$(tail -n 1 /var/www/vasiliipopov.hopto.org/nginx_logs/4xx.log)
if [[ "$last_line_4xx_response_saved_log" == "" ]]; then
    echo "TRUE"
fi