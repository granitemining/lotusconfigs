#!/usr/bin/env bash

## Courtesy of Patrick - Factor8 Solutions
## DO NOT USE ON MAINNET!!
## Modifications by me :)

INITIAL_SLEEP_TIME=0
LOOP_SLEEP_TIME=900 # 900 seconds = 15 minutes
PLEDGE_COUNTER=0
WITHDRAWL_INTERVAL=10

sleep $INITIAL_SLEEP_TIME

while [ $PLEDGE_COUNTER -le 320 ]
do
    lotus-miner sectors pledge
    let PLEDGE_COUNTER++
    if ! (( $PLEDGE_COUNTER % $WITHDRAWL_INTERVAL )) ; then
        lotus-miner actor withdraw &
    fi
    sleep $LOOP_SLEEP_TIME
done
exit 0

## DO NOT USE ON MAINNET!!
