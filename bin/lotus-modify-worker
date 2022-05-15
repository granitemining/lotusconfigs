#!/usr/bin/env bash

dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/.utils.sh"

_get_worker # returns $wreponame and $wrepopath
. "$wrepopath/$wreponame.env"

while [[ "$correct" != "y" ]]
do
    read -p "AddPiece?   [true/false] " -i $LOTUS_CUSTOM_ADDPIECE -e LOTUS_CUSTOM_ADDPIECE
    read -p "PreCommit1? [true/false] " -i $LOTUS_CUSTOM_PRECOMMIT1 -e LOTUS_CUSTOM_PRECOMMIT1
    read -p "PreCommit2? [true/false] " -i $LOTUS_CUSTOM_PRECOMMIT2 -e LOTUS_CUSTOM_PRECOMMIT2
    read -p "Commit?     [true/false] " -i $LOTUS_CUSTOM_COMMIT -e LOTUS_CUSTOM_COMMIT
    read -p "Unseal?     [true/false] " -i $LOTUS_CUSTOM_UNSEAL -e LOTUS_CUSTOM_UNSEAL
    read -p "CPU group: "             -i $LOTUS_CUSTOM_CPUGROUP -e LOTUS_CUSTOM_CPUGROUP
    read -p "Port: "                  -i $LOTUS_CUSTOM_PORT -e LOTUS_CUSTOM_PORT
    read -p "IP: "                    -i $LOTUS_CUSTOM_IP -e LOTUS_CUSTOM_IP
    read -p "GPUs: "                  -i $LOTUS_CUSTOM_GPUS -e LOTUS_CUSTOM_GPUS
    read -p "Timeout: "               -i $LOTUS_CUSTOM_TIMEOUT -e LOTUS_CUSTOM_TIMEOUT
    read -p "Multicore? [1/0] "       -i $FIL_PROOFS_USE_MULTICORE_SDR -e FIL_PROOFS_USE_MULTICORE_SDR
    read -p "Is the above correct? [y/n] " -e correct
done

_modify_config
