#!/bin/bash

if [ -z "$DESKTOP_SESSION" ] && [ -z "$VIMRUNTIME" ]; then

    MINTTY_COUNT_FILE="$HOME/.keychain/mintty_count"

function start_agent {
    if [ ! -e "$MINTTY_COUNT_FILE" ]; then
        echo 'export MINTTY_COUNT=1' > "$MINTTY_COUNT_FILE"
        chmod 600 "${MINTTY_COUNT_FILE}"
    fi
    eval `keychain -q --eval --ignore-missing --agents ssh id_rsa`
}

function stop_agent {
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
        . "${MINTTY_COUNT_FILE}" 2>/dev/null
        echo "export MINTTY_COUNT=$((MINTTY_COUNT+1))" > "$MINTTY_COUNT_FILE"
        unset MINTTY_COUNT
        start_agent;
        trap stop_agent 0
    fi
fi
