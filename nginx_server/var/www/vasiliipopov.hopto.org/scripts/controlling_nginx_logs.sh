#!/bin/bash

IFS=$'\n'

check_line_is_4xx() {
    # Не под все строчки попадает, нужен regex для поиска ", ищем затем следующую " и после неё берём три цифры
    status=$(echo $1 | awk '{ print $9 }')
    echo "Status is $status"
    if [[ "$status" =~ 4[0-9]{2} ]]; then
        this_line_is_4xx=true
        echo "This line is 4xx"
    else
        this_line_is_4xx=false
    fi
}

check_line_is_5xx() {
    status=$(echo $1 | awk '{ print $9 }')
    echo "Status is $status"
    if [[ "$status" =~ 5[0-9]{2} ]]; then
        this_line_is_5xx=true
        echo "This line is 5xx"
    else
        this_line_is_5xx=false
    fi
}

while true
do
    last_line_4xx_response_saved_log=$(tail -n 1 /var/www/vasiliipopov.hopto.org/nginx_logs/4xx.log)
    last_line_5xx_response_saved_log=$(tail -n 1 /var/www/vasiliipopov.hopto.org/nginx_logs/5xx.log)
    last_line_internal_errors_saved_log=$(tail -n 1 /var/www/vasiliipopov.hopto.org/nginx_logs/internal_errors.log)
    
    found_last_4xx=false
    found_last_5xx=false
    found_last_internal_error=false
    
    for line in $(cat /var/log/nginx/access.log)
    do
        if [[ "$found_last_4xx" == "true" ]] || [[ "$last_line_4xx_response_saved_log" == "" ]]; then
            echo "Checking line is 4xx"
            check_line_is_4xx $line
            if [[ "$this_line_is_4xx" == "true" ]]; then
                echo $line >> /var/www/vasiliipopov.hopto.org/nginx_logs/4xx.log
            fi
        fi
        
        if [[ "$found_last_5xx" == "true" ]] || [[ "$last_line_5xx_response_saved_log" == "" ]]; then
            echo "Checking line is 5xx"
            check_line_is_5xx $line
            if [[ "$this_line_is_5xx" == "true" ]]; then
                echo $line >> /var/www/vasiliipopov.hopto.org/nginx_logs/5xx.log
            fi
        fi
        
        if [[ "$line" == "$last_line_4xx_response_saved_log" ]]; then
            found_last_4xx=true
        fi
        
        if [[ "$line" == "$last_line_5xx_response_saved_log" ]]; then
            found_last_5xx=true
        fi
    done

    if [[ $(ls -l --block-size KB /var/www/vasiliipopov.hopto.org/nginx_logs/4xx.log | awk '{ print $5 }') =~ "?[0-9]*[3-9]kB" ]]; then
        > /var/www/vasiliipopov.hopto.org/nginx_logs/4xx.log
        { date ; echo "Произведена очистка файла" ; } | tr "\n" " " >> /var/www/vasiliipopov.hopto.org/clean_logs/4xx.log
    fi
    
    if [[ $(ls -l --block-size KB /var/www/vasiliipopov.hopto.org/nginx_logs/5xx.log | awk '{ print $5 }') =~ "?[0-9]*[3-9]kB" ]]; then
        > /var/www/vasiliipopov.hopto.org/nginx_logs/5xx.log
        { date ; echo "Произведена очистка файла" ; } | tr "\n" " " >> /var/www/vasiliipopov.hopto.org/clean_logs/5xx.log
    fi
    
    sleep 5

done