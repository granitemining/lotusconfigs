#!/usr/bin/env bash

dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/.utils.sh"

while [[ "$correct" != "y" ]]
do
  read -p "Worker name: "                         -i $wreponame -e wreponame
  read -p "Bellman CPU utilization: "             -i $BELLMAN_CPU_UTILIZATION -e BELLMAN_CPU_UTILIZATION
  read -p "AddPiece? [false] "                    -i $LOTUS_CUSTOM_ADDPIECE -e LOTUS_CUSTOM_ADDPIECE
  read -p "PreCommit1? [false] "                  -i $LOTUS_CUSTOM_PRECOMMIT1 -e LOTUS_CUSTOM_PRECOMMIT1
  read -p "PreCommit2? [false] "                  -i $LOTUS_CUSTOM_PRECOMMIT2 -e LOTUS_CUSTOM_PRECOMMIT2
  read -p "Commit? [false] "                      -i $LOTUS_CUSTOM_COMMIT -e LOTUS_CUSTOM_COMMIT
  read -p "Unseal? [false] "                      -i $LOTUS_CUSTOM_UNSEAL -e LOTUS_CUSTOM_UNSEAL
  read -p "Replica update? [false] "              -i $LOTUS_CUSTOM_REPLICA_UPDATE -e LOTUS_CUSTOM_REPLICA_UPDATE
  read -p "Prove replica update 2? [false] "      -i $LOTUS_CUSTOM_PROVE_REPLICA_UPDATE2 -e LOTUS_CUSTOM_PROVE_REPLICA_UPDATE2
  read -p "Regen sector key? [false] "            -i $LOTUS_CUSTOM_REGEN_SECTOR_KEY -e LOTUS_CUSTOM_REGEN_SECTOR_KEY
  read -p "CPU group: "                           -i $LOTUS_CUSTOM_CPUGROUP -e LOTUS_CUSTOM_CPUGROUP
  read -p "Port: "                                -i $LOTUS_CUSTOM_PORT -e LOTUS_CUSTOM_PORT
  read -p "GPUs: "                                -i $CUDA_VISIBLE_DEVICES -e CUDA_VISIBLE_DEVICES
  read -p "Multicore? [1/0] "                     -i $FIL_PROOFS_USE_MULTICORE_SDR -e FIL_PROOFS_USE_MULTICORE_SDR
  read -p "Is the above correct? [y/n] " -e correct
done

wrepopath="$HOME/.lotusworkers/$wreponame"
mkdir -p $wrepopath/tmpdir

_modify_config
_start_worker
