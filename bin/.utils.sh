# Usage: _get_worker
function _get_worker
{
    while :
    do
	read -p "Worker name: " -i $wreponame -e wreponame
	wrepopath="$HOME/.lotusworkers/$wreponame"
	if [ ! -d "$wrepopath" ] ; then
	    echo "$wreponame does not exist."
	    echo "Use create-worker.sh to create it first."
	    continue
	fi
	break
    done
}

# Usage: _start_worker
function _start_worker
{
    read -p "Start $wreponame now? [y/n] " -r start
    if [[ "$start" == "y" ]] ; then
	source $wrepopath/$wreponame.env
	cgexec -g cpuset:$LOTUS_CUSTOM_CPUGROUP --sticky lotus-worker run \
		--listen=$LOTUS_CUSTOM_IP:$LOTUS_CUSTOM_PORT \
		--addpiece=${LOTUS_CUSTOM_ADDPIECE:=false} \
		--precommit1=${LOTUS_CUSTOM_PRECOMMIT1:=false} \
		--precommit2=${LOTUS_CUSTOM_PRECOMMIT2:=false} \
		--commit=${LOTUS_CUSTOM_COMMIT:=false} \
		--unseal=${LOTUS_CUSTOM_UNSEAL:=false} \
		--replica-update=${LOTUS_CUSTOM_REPLICA_UPDATE:=false} \
		--prove-replica-update2=${LOTUS_CUSTOM_PROVE_REPLICA_UPDATE2:=false} \
		--regen-sector-key=${LOTUS_CUSTOM_REGEN_SECTOR_KEY:=false}
    fi
}

# Usage: _modify_config
function _modify_config
{
    cat << EOT > $wrepopath/$wreponame.env
export BELLMAN_CPU_UTILIZATION=$BELLMAN_CPU_UTILIZATION
export FIL_PROOFS_USE_MULTICORE_SDR=$FIL_PROOFS_USE_MULTICORE_SDR
export TMPDIR="$wrepopath/tmpdir"
export CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES
export LOTUS_WORKER_PATH=$wrepopath
export LOTUS_CUSTOM_ADDPIECE=$LOTUS_CUSTOM_ADDPIECE
export LOTUS_CUSTOM_PRECOMMIT1=$LOTUS_CUSTOM_PRECOMMIT1
export LOTUS_CUSTOM_PRECOMMIT2=$LOTUS_CUSTOM_PRECOMMIT2
export LOTUS_CUSTOM_COMMIT=$LOTUS_CUSTOM_COMMIT
export LOTUS_CUSTOM_UNSEAL=$LOTUS_CUSTOM_UNSEAL
export LOTUS_CUSTOM_REPLICA_UPDATE=$LOTUS_CUSTOM_REPLICA_UPDATE
export LOTUS_CUSTOM_PROVE_REPLICA_UPDATE2=$LOTUS_CUSTOM_PROVE_REPLICA_UPDATE2
export LOTUS_CUSTOM_REGEN_SECTOR_KEY=$LOTUS_CUSTOM_REGEN_SECTOR_KEY
export LOTUS_CUSTOM_PORT=$LOTUS_CUSTOM_PORT
export LOTUS_CUSTOM_CPUGROUP=$LOTUS_CUSTOM_CPUGROUP
EOT
}
