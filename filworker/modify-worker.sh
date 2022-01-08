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

correct='n'
while [[ "$correct" != "y" ]]
do
    read -p "AddPiece? [y/n] >" -i
