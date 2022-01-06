#!/usr/bin/env bash

set -x
trap read debug

correct='n'
while [ $correct -ne 'y' ]
do
  echo -n "Name of worker [leave blank for random]: "; read -r wreponame
  echo -n "AddPiece? [y]: "; read -r addpiece
  echo -n "PreCommit1? [y]: "; read -r precommit1
  echo -n "PreCommit2? [y]: "; read -r precommit2
  echo -n "Commit? [y]: "; read -r commit
  echo -n "Unseal? [y]: "; read -r unseal
  echo -n "Port: "; read -r port
  echo -n "CPUs: "; read -r cpus
  echo -n "MEMs: "; read -r mems
  echo -n "GPUs: "; read -r gpus
  echo -n "Timeout [0]: "; read -r timeout
  echo -n "Is the above correct? [y]: "; read -r correct
done

source .utils.sh

wrepopath=$(.createwrepo $wreponame)
wcgrouppath=$(.createwcgroup $wreponame)
wcgroupname=$(basename $wcgrouppath)

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
export TMPDIR='/fil/sealing'
export CUDA_VISIBLE_DEVICES=$gpu
export LOTUS_WORKER_PATH=$wrepopath

if cgexec -g cpuset:$wcgroupname --sticky nohup lotus-worker run --listen=10.0.0.243:$port --addpiece=$addpiece --precommit1=$precommit1 --precommit2=$precommit2 --commit=$commit --unseal=$unseal --timeout=$timeout > $wrepopath/$wreponame.log 2>&1 & ; then
  lotus-worker storage attach --seal /fil/sealing
  lotus-worker info
fi
