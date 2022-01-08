#!/usr/bin/env bash

: <<'END'
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo "Not running as root. Quitting..."
  exit
fi
END

correct='n'
while [[ "$correct" != "y" ]]
do
  read -p "Name of worker: " -i $wreponame -e wreponame
  if [ -d "/fil/sealing/$wreponame" ] ; then
    echo "$wreponame already exists."
    echo "If you want to modify an existing worker, please use modify-worker.sh instead."
    continue
  fi

  read -p "AddPiece? [y/n] "   -i $addpiece -e addpiece
  read -p "PreCommit1? [y/n] " -i $precommit1 -e precommit1
  read -p "PreCommit2? [y/n] " -i $precommit2 -e precommit2
  read -p "Commit? [y/n] "     -i $commit -e commit
  read -p "Unseal? [y/n] "     -i $unseal -e unseal
  read -p "CPU group: "             -i $cpus -e cpus
  read -p "MEMs: "                  -i $mems -e mems
  read -p "Port: "                  -i $port -e port
  read -p "IP: "                    -i $ip -e ip
  read -p "GPUs: "                  -i $gpus -e gpus
  read -p "Timeout: "               -i $timeout -e timeout
  read -p "Is the above correct? [y/n] " -e correct
done

source .utils.sh

# Sanitize inputs
addpiece=$(.sanitizebool $addpiece)
precommit1=$(.sanitizebool $precommit1)
precommit2=$(.sanitizebool $precommit2)
commit=$(.sanitizebool $commit)
unseal=$(.sanitizebool $unseal)

wrepopath="/fil/sealing/$wreponame"
mkdir -p $wrepopath $wrepopath/tmpdir

cat << EOT >> $wrepopath/$wreponame.env
export BELLMAN_CPU_UTILIZATION=0.875
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_PARAMETER_CACHE='/fil/parameters'
export FIL_PROOFS_PARENT_CACHE='/fil/parents'
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
export FIL_PROOFS_USE_MULTICORE_SDR=0
export FIL_PROOFS_MULTICORE_SDR_PRODUCERS=2
export FULLNODE_API_INFO='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.o7vVP3Ar8Y3aVXDXgxEiAw7k_OnVvAwY3gQ8hMwdx0Q:/ip4/10.0.0.76/tcp/18001/http'
export MINER_API_INFO='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.tXpA8Aii09eQz0Rh1nU4zsZb-pDaJjd3X6cZV5LcG4M:/ip4/10.0.0.76/tcp/18002/http'
export TMPDIR="$wrepopath/tmpdir"
export CUDA_VISIBLE_DEVICES=$gpus
export LOTUS_WORKER_PATH=$wrepopath
export LOTUS_CUSTOM_ADDPIECE=$addpiece
export LOTUS_CUSTOM_PRECOMMIT1=$precommit1
export LOTUS_CUSTOM_PRECOMMIT2=$precommit2
export LOTUS_CUSTOM_COMMIT=$commit
export LOTUS_CUSTOM_UNSEAL=$unseal
export LOTUS_CUSTOM_IP=$ip
export LOTUS_CUSTOM_PORT=$port
export LOTUS_CUSTOM_TIMEOUT=$timeout
export LOTUS_CUSTOM_CPUGROUP=$cpus
EOT

read -p "Start $wreponame now? [y/n] " -r start
if [[ "$start" == "y" ]] ; then
  source $wrepopath/$wreponame.env
  cgexec -g cpuset:$cpus --sticky lotus-worker run --listen=$ip:$port --addpiece=$addpiece --precommit1=$precommit1 --precommit2=$precommit2 --commit=$commit --unseal=$unseal --timeout=$timeout
fi
