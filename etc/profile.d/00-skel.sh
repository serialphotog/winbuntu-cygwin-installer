#!/bin/bash

[ -n "$SKEL_FINISHED" ] && return

# use windows shortcuts as symlinks
export CYGWIN="${CYGWIN}${CYGWIN:+ }winsymlinks"

# bind user profile directory
[ ! -e "$HOME/.userprofile" ] && mount -fo user "$USERPROFILE" ~/.userprofile

# ensure skeleton files are updated for new packages
for bone in `find /etc/skel -type f -printf "%P\n"`; do
    if [ ! -e $HOME/$bone ]; then
        mkdir -p `dirname $HOME/$bone`
        cp /etc/skel/$bone $HOME/$bone
    fi
done

SKEL_FINISHED=1
