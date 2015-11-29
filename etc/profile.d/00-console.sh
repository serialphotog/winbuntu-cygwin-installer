#!/bin/bash

export ENV_FILE="/var/run/env"
export ENV_COUNT_FILE="/var/run/count"

[ "$SHLVL" -eq "1" ] || return

function _start_login {
    touch "$ENV_FILE"
    if [ "$TERM" != "cygwin" ]; then
        if [ ! -e "$ENV_COUNT_FILE" ]; then
            echo -n '1' > "$ENV_COUNT_FILE"
        else
            sh_count=$(cat $ENV_COUNT_FILE)
            echo "$((sh_count+1))" > "$ENV_COUNT_FILE"
        fi
    fi
    eval `cat $ENV_FILE`
    function keep_env() {
        touch $ENV_FILE
        cat $ENV_FILE | grep -ve "^export\\s$1" > $ENV_FILE
        echo "export $1=${!1};" >> $ENV_FILE
    }
    function on_logout() {
        current_trap=$(trap -p 0 | awk '{print $3}' | sed "s/'//g")
        trap "${current_trap}${current_trap:+;}$1" 0
    }
    for fil in /etc/login.d/*; do
        . "$fil"
    done
    on_logout '_logout'
}

function _logout {
    if [ "$TERM" != "cygwin" ]; then
        sh_count=$(cat /var/run/count)
        if [ "$sh_count" -le 1 ]; then
            echo -e '\n * shutting down'
    	    rm -f /var/run/count
            rm -f /var/run/env
        else 
    	    echo "$((sh_count-1))" > /var/run/count
        fi
    fi
}

_start_login

