#!/usr/bin/env bash

while :
do
    read -p "Modify which worker? >" -i $wreponame -e wreponame
    if [ ! -d "/fil/sealing/$wreponame" ] ; then
        echo "$wreponame does not exist."
        echo "Use create-worker.sh to create it first."
        continue
    fi
    break
done

wrepopath="/fil/sealing/$wreponame"

source .utils.sh
source $wrepopath/$wreponame.env

addpiece=$LOTUS_CUSTOM_ADDPIECE
precommit1=$LOTUS_CUSTOM_PRECOMMIT1
precommit2=$LOTUS_CUSTOM_PRECOMMIT2
commit=$LOTUS_CUSTOM_COMMIT
unseal=$LOTUS_CUSTOM_UNSEAL
cpugroup=$LOTUS_CUSTOM_CPUGROUP
multicore=$FIL_PROOFS_USE_MULTICORE_SDR
gpus=$CUDA_VISIBLE_DEVICES
timeout=$LOTUS_CUSTOM_TIMEOUT
port=$LOTUS_CUSTOM_PORT
ip=$LOTUS_CUSTOM_IP

while [[ "$correct" != "y" ]]
do
    read -p "AddPiece? [y/n] >"  -i $addpiece -e addpiece
    read -p "PreCommit1? [y/n] " -i $precommit1 -e precommit1
    read -p "PreCommit2? [y/n] " -i $precommit2 -e precommit2
    read -p "Commit? [y/n] "     -i $commit -e commit
    read -p "Unseal? [y/n] "     -i $unseal -e unseal
    read -p "CPU group: "             -i $cpus -e cpus
    read -p "Port: "                  -i $port -e port
    read -p "IP: "                    -i $ip -e ip
    read -p "GPUs: "                  -i $gpus -e gpus
    read -p "Timeout: "               -i $timeout -e timeout
    read -p "Multicore? [1/0] "       -i $multicore -e multicore    
    read -p "Is the above correct? [y/n] " -e correct
done

cat << EOT > $wrepopath/$wreponame.env
export BELLMAN_CPU_UTILIZATION=0.875
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_PARAMETER_CACHE='/fil/parameters'
export FIL_PROOFS_PARENT_CACHE='/fil/parents'
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
export FIL_PROOFS_USE_MULTICORE_SDR=$multicore
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
