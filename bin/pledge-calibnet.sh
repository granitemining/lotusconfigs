#!/usr/bin/env bash

## Courtesy of Patrick - Factor8 Solutions
## DO NOT USE ON MAINNET!!
## Modifications by me :)

# Metrics at a glance
# 2760 seconds = 46 minutes   (~1TB/day)
# 1380 seconds = 23 minutes   (~2TB/day)
# 900 seconds  = 15 minutes   (~3TB/day)
# 690 seconds  = 11.5 minutes (~4TB/day)
# 540 seconds  = 9 minutes    (~5TB/day)
LOOP_SLEEP_TIME=1380

INITIAL_SLEEP_TIME=0
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
