#!/bin/bash

if [ -z "$DESKTOP_SESSION" ] && [ "$SHLVL" -eq "1" ]; then

    MINTTY_COUNT_FILE="$HOME/.keychain/mintty_count"

function _start_agent {
    if [ ! -e "$MINTTY_COUNT_FILE" ]; then
        echo 'export MINTTY_COUNT=1' > "$MINTTY_COUNT_FILE"
        chmod 600 "${MINTTY_COUNT_FILE}"
    fi
    eval `keychain -q -Q --eval --ignore-missing --agents ssh id_rsa`
}

function _stop_agent {
    . "$MINTTY_COUNT_FILE"
    if [ "$MINTTY_COUNT" -le 1 ]; then
	rm -f $MINTTY_COUNT_FILE
        eval `keychain -q --eval -k all`
    else 
	echo "export MINTTY_COUNT=$((MINTTY_COUNT-1))" > "$MINTTY_COUNT_FILE"
    fi
}

# Source SSH settings, if applicable
    if [ -e "$HOME/.ssh/id_rsa" ]; then
        mkdir -p $(dirname $MINTTY_COUNT_FILE)
        . "${MINTTY_COUNT_FILE}" 2>/dev/null
        echo "export MINTTY_COUNT=$((MINTTY_COUNT+1))" > "$MINTTY_COUNT_FILE"
        unset MINTTY_COUNT
        _start_agent;
        trap _stop_agent 0
    fi
fi
