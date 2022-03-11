#!/usr/bin/env bash

while [[ "$correct" != "y" ]]
do
    read -p "Where are the workers? >" -i $workers -e workers
    if [ ! -d "$workers" ]; then
        echo "Directory $workers does not exist."
	echo "Please try again."
	continue
    fi

    read -p "Where is the shared sealing store? >" -i $sealstore -e sealstore
    if [ ! -d "$sealstore" ]; then
	echo "Directory $sealstore does not exist."
	echo "Please try again."
	continue
    fi

    read -p "Is everything correct? [y/n] >" -e correct
done

for d in $workers/*/; do

    # Check if repo belongs to registered worker.
    storage="${d}storage.json"
    if [ ! -f "$storage" ]; then
	echo "$d is not a registered worker. Skipping..."
	continue
    fi

    # Check if registered worker has already been updated
    isupdated=$(cat $storage | jq '(.StoragePaths[] | select(.Path == "/fil/sealing-aux")) // empty')
    if [ ! -z "$isupdated" ]; then
	echo "$d is already updated. Skipping..."
	continue
    fi

    # Update storage paths in $worker/storage.json
    cat $storage | jq '.StoragePaths += [{"Path": "/fil/sealing-aux"}]' | sponge $storage
    echo "Finished updating $d!"
done
