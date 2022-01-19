#!/usr/bin/env bash

while read -r line
do
    jobid=$(echo "$line" | awk '{print $1;}')
    echo $jobid
    if [[ "$jobid" =~ [[:alnum:]{8}] ]] ; then
	echo "$jobid is a valid job ID"
    fi

    exit
    
    read -p "Delete job $jobid? [y/n] " -r confirm
    if [[ "$confirm" == "y" ]] ; then
	lotus-miner sealing abort $jobid
    fi

done < <(lotus-miner sealing jobs)    
