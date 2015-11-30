#!/bin/bash

[ -z "$DESKTOP_SESSION" ] && [ "$TERM" != "cygwin" ] || return

function _start_agent {
    eval `keychain -q -Q --eval --ignore-missing --agents ssh id_rsa`
    on_logout '_stop_agent'
}

function _stop_agent {
    count=$(cat $ENV_COUNT_FILE)
    if [ "$count" -le 1 ]; then
        eval `keychain -q --eval -k all`
    fi
}

# Source SSH settings, if applicable
if [ -e "$HOME/.ssh/id_rsa" ]; then
    _start_agent
fi

