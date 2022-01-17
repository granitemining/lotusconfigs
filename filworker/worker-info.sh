#!/usr/bin/env bash

while :
do
    read -p "Get info of which worker? >" -i $wreponame -e wreponame
    if [ ! -d "/fil/sealing/$wreponame" ] ; then
	echo "$wreponame does not exist."
	echo "Use create-worker.sh to create it first."
	continue
    fi
    break
done

wrepopath="/fil/sealing/$wreponame"

lotus-worker --worker-repo=$wrepopath info

read -p "Press [enter] to continue..."

source $wrepopath/$wreponame.env
ip=$LOTUS_CUSTOM_IP
port=$LOTUS_CUSTOM_PORT
pid=$(pgrep -f listen=$ip:$port)

strings /proc/$pid/environ
