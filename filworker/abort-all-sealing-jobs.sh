#!/usr/bin/env bash

while IFS= read line
do
    jobid=$(echo "$line" | awk '{print $1;}')    

    if ! [[ "$jobid" =~ ^[a-f0-9]{8} ]] ; then
	continue
    fi

    if [[ "$jobid" == "00000000" ]] ; then
	echo "Skipping $jobid..."
	continue
    fi
    
    read -p "Delete job $jobid? [y/n] " -r confirm
    if [[ "$confirm" == "y" ]] ; then
	lotus-miner sealing abort $jobid
    fi

done <<< $(lotus-miner sealing jobs)    
