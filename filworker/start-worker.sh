#!/usr/bin/env bash

while :
do
    read -p "Start which worker? >" -i $wreponame -e wreponame
    if [ ! -d "/fil/sealing/$wreponame" ] ; then
        echo "$wreponame does not exist."
        echo "Use create-worker.sh to create it first."
        continue
    fi
    break
done

read -p "Start $wreponame now? [y/n] >" -r start
if [[ "$start" == "y" ]] ; then
    wrepopath=/fil/sealing/$wreponame
    source $wrepopath/$wreponame.env
    cgexec -g cpuset:$LOTUS_CUSTOM_CPUGROUP --sticky lotus-worker run --listen=$LOTUS_CUSTOM_IP:$LOTUS_CUSTOM_PORT --addpiece=$LOTUS_CUSTOM_ADDPIECE --precommit1=$LOTUS_CUSTOM_PRECOMMIT1 --precommit2=$LOTUS_CUSTOM_PRECOMMIT2 --commit=$LOTUS_CUSTOM_COMMIT --unseal=$LOTUS_CUSTOM_UNSEAL --timeout=$LOTUS_CUSTOM_TIMEOUT
fi
    

