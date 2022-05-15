#!/usr/bin/env bash

dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/.utils.sh"

_get_worker
lotus-worker --worker-repo=$wrepopath info
