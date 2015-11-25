#!/bin/bash

if [ "$TERM" != "cygwin" ] && [ -z "$DESKTOP_SESSION" ]; then
  SSH_ENV="$HOME/.ssh/environment"
  MINTTY_COUNT_FILE="$HOME/.mintty_count"

  function start_agent {
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo 'export MINTTY_COUNT=1' > "$MINTTY_COUNT_FILE"
    chmod 600 "${SSH_ENV}"
    chmod 600 "${MINTTY_COUNT_FILE}"
    . "${SSH_ENV}" > /dev/null
    #echo -e "\e[1;30m ssh-agent started\n run 'ssh-add' to remember keys\e[0m"
  }

  function stop_agent {
	. "$MINTTY_COUNT_FILE"
	if [ "$MINTTY_COUNT" -le 1 ]; then
		#echo -e "\e[1;30m\nssh-agent exiting"
		echo -e "\e[1;30m"
		rm -f $MINTTY_COUNT_FILE
		rm -f $SSH_ENV
		ssh-add -D 2>/dev/null
		eval `/usr/bin/ssh-agent -k`
		#sleep 1
	else 
		echo "export MINTTY_COUNT=$((MINTTY_COUNT-1))" > "$MINTTY_COUNT_FILE"
	fi
  }

  # Source SSH settings, if applicable
  if [ -e "$HOME/.ssh" ]; then
    if [ -f "${SSH_ENV}" ]; then
         . "${SSH_ENV}" > /dev/null
         . "${MINTTY_COUNT_FILE}" > /dev/null
         echo "export MINTTY_COUNT=$((MINTTY_COUNT+1))" > "$MINTTY_COUNT_FILE"
         unset MINTTY_COUNT
         #ps ${SSH_AGENT_PID} doesn't work under cywgin
         ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
             start_agent;
         }
    else
         start_agent;
    fi
    trap stop_agent 0
  fi
fi

