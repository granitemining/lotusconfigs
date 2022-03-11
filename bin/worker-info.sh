#!/usr/bin/env bash

dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/.utils.sh"

_get_worker

# Print worker info
lotus-worker --worker-repo=$wrepopath info
read -p "Press [enter] to continue..."

# Print environment
source $wrepopath/$wreponame.env
pid=$(pgrep -f listen=0.0.0.0:$LOTUS_CUSTOM_PORT)
strings /proc/$pid/environ
