# Usage: _get_worker
# Expects null
# Returns $wreponame | $wrepopath
function _get_worker
{
    while :
    do
	read -p "Worker name: " -i $wreponame -e wreponame
	wrepopath="/fil/lotusworkers/$wreponame"
	if [ ! -d "$wrepopath" ] ; then
	    echo "$wreponame does not exist."
	    echo "Use create-worker.sh to create it first."
	    continue
	fi
	break
    done
}

# Usage: _start_worker
# Expects $wrepopath | $wreponame
# Returns null
function _start_worker
{
    read -p "Start $wreponame now? [y/n] " -r start
    if [[ "$start" == "y" ]] ; then
	source $wrepopath/$wreponame.env
	cgexec -g cpuset:$LOTUS_CUSTOM_CPUGROUP --sticky lotus-worker run --listen=$LOTUS_CUSTOM_IP:$LOTUS_CUSTOM_PORT --addpiece=$LOTUS_CUSTOM_ADDPIECE --precommit1=$LOTUS_CUSTOM_PRECOMMIT1 --precommit2=$LOTUS_CUSTOM_PRECOMMIT2 --commit=$LOTUS_CUSTOM_COMMIT --unseal=$LOTUS_CUSTOM_UNSEAL --timeout=$LOTUS_CUSTOM_TIMEOUT
    fi
}

# Usage: _modify_config
# Expects $wrepopath | $wreponame | $FIL_PROOFS_USE_MULTICORE_SDR | $LOTUS_CUSTOM_GPUS | $LOTUS_CUSTOM_ADDPIECE | $LOTUS_CUSTOM_PRECOMMIT1 | $LOTUS_CUSTOM_PRECOMMIT2 | $LOTUS_CUSTOM_COMMIT | $LOTUS_CUSTOM_UNSEAL | $LOTUS_CUSTOM_IP | $LOTUS_CUSTOM_PORT | $LOTUS_CUSTOM_TIMEOUT | $LOTUS_CUSTOM_CPUGROUP
# Returns null
function _modify_config
{
    cat << EOT > $wrepopath/$wreponame.env
export BELLMAN_CPU_UTILIZATION=0.875
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
export FIL_PROOFS_USE_MULTICORE_SDR=$FIL_PROOFS_USE_MULTICORE_SDR
export FIL_PROOFS_MULTICORE_SDR_PRODUCERS=2
export TMPDIR="$wrepopath/tmpdir"
export CUDA_VISIBLE_DEVICES=$LOTUS_CUSTOM_GPUS
export LOTUS_WORKER_PATH=$wrepopath
export LOTUS_CUSTOM_ADDPIECE=$LOTUS_CUSTOM_ADDPIECE
export LOTUS_CUSTOM_PRECOMMIT1=$LOTUS_CUSTOM_PRECOMMIT1
export LOTUS_CUSTOM_PRECOMMIT2=$LOTUS_CUSTOM_PRECOMMIT2
export LOTUS_CUSTOM_COMMIT=$LOTUS_CUSTOM_COMMIT
export LOTUS_CUSTOM_UNSEAL=$LOTUS_CUSTOM_UNSEAL
export LOTUS_CUSTOM_IP=$LOTUS_CUSTOM_IP
export LOTUS_CUSTOM_PORT=$LOTUS_CUSTOM_PORT
export LOTUS_CUSTOM_TIMEOUT=$LOTUS_CUSTOM_TIMEOUT
export LOTUS_CUSTOM_CPUGROUP=$LOTUS_CUSTOM_CPUGROUP
EOT
}
