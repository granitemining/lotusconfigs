#!/usr/bin/env bash

dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/.utils.sh"

_get_worker
lotus-worker --worker-repo=$wrepopath info

read -p "Press [enter] to continue..."

source $wrepopath/$wreponame.env
pid=$(pgrep -f listen=$LOTUS_CUSTOM_IP:$LOTUS_CUSTOM_PORT)

strings /proc/$pid/environ
