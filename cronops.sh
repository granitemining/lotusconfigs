#!/bin/bash

###
#
# USAGE
#
# 1 - Move this script to your CRONJOBS folder
# 2 - Create a new croninit.sh script using the CRONINIT TEMPLATE below
# 3 - Schedule cronjobs using the format: /loc/to/croninit <option> "Email Subject"
#
###

### START CRONINIT TEMPLATE ###

#export BOT_EMAIL=bot@ops.sandford.pub
#export TEAM_EMAIL=daily@ops.sandford.pub
#export ALERT_EMAIL=alerts@ops.sandford.pub
#export SUBJECT=$2

#export HOSTNAME=$(hostname)
#export HOME=/home/mainnet
#export LOCKFILE=/home/mainnet/.lotusminer/repo.lock
#export ROOTDISK=/dev/sdcm2
#export ROOTDISKPERC= #not implemented!
#export DISKALT1=
#export DISKALT1PERC=
#export DISKALT2=
#export DISKALT2PERC=

#export CRONJOBS=/home/mainnet/cronjobs
#export CRONOPS=$CRONJOBS/cronops.sh
#export CRONOPS_REMOTE=/fil/common/repos/lotusconfigs/bin/cronops.sh

#export SHELL=/usr/bin/bash
#export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#export MAILTO=""
#export FULLNODE_API_INFO=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.CzpMkM0Xn7ODmQWGJANazqaezSxhwo_7qhvtv7q-50Q:/ip4/10.10.0.40/tcp/18100/http

#if [ -f "$CRONOPS_REMOTE" ]; then
#  echo "Connected to remote script source..."
#  ISCHANGED="$(diff $CRONOPS $CRONOPS_REMOTE | wc -l)"
#  if [ $ISCHANGED -gt 0 ]; then
#    echo "New cronops script found, updating..."
#    cp $CRONOPS_REMOTE $CRONOPS
#  else
#    echo "Remote cronops matches existing, no change..."
#  fi
#else
#  echo "ALERT: remote cronops script not accessible, using existing..."
#fi

#$CRONOPS $1 $2

### END CRONINIT TEMPLATE ###

### SAMPLE CRONTABLE ###

# * * * * * /home/mainnet/cronjobs/croninit.sh nodealert "Node Online Alert" >> /tmp/cronlog.log
# * * * * * /home/mainnet/cronjobs/croninit.sh rootdiskalert "Root Disk Alert" >> /tmp/cronlog.log
# 0 6 * * * /home/mainnet/cronjobs/croninit.sh dailyreport "Morning dailyreport run" >> /tmp/cronlog.log
# 0 18 * * * /home/mainnet/cronjobs/croninit.sh dailyreport "Evening dailyreport run" >> /tmp/cronlog.log
# 59 23 * * * rm /tmp/cronlog-last24.log ; mv /tmp/cronlog.log /tmp/cronlog-last24.log

### CRONOPS SCRIPT ###

export LOG="/tmp/cronops.log.$RANDOM.log"
export ALERT="/tmp/cronops.alert.$RANDOM.log"
export OPTIONS=("diskcheck" "zfscheck" "mpoolcheck" "sectorscheck" "wpostcheck" "walletcheck" "allchecks" "dailyreport" "wpostalert" "nodealert" "rootdiskalert" "alldisksalert")
export OPTION_FOUND=0
export NEW_ALERT=0
export SEND_EMAIL=1

function main(){
  CUR_TIME=$(date +"%Y-%m-%d %T")
  echo "Initializing cronops.sh script on $HOSTNAME at $CUR_TIME" > $LOG

  if [[ -z $1 ]]; then
    printhelp
    exit
  fi

  printf "\nAttempting to run $1 function...\n" >> $LOG

  # run function
  for OPTION in ${OPTIONS[@]}; do
    if [[ $OPTION == $1 ]]; then
      OPTION_FOUND=1
      echo "Found $1, attempting to run..." >> $LOG
      eval ${OPTION}
      break
    fi
  done

  # check to see if we should send an email
  if [ $OPTION_FOUND -eq 1 ]; then
    cat $LOG
    if [ -z "$SUBJECT" ]; then
      SUBJECT="Cronops Run"
    fi
    if [ $SEND_EMAIL -eq 1 ]; then
      emailer "$SUBJECT" "$LOG"
    fi
  else
    echo "Please enter a valid option: "
    printhelp
  fi

  #cleanup temp file
  rm $LOG
}

function diskcheck() {
  COMMAND="df --output=pcent,source -h -t 'ext4' -t 'zfs' -t 'nfs'"
  TEXT="Disk usage check"
  runcommand "$COMMAND" "$TEXT"
}

function mpoolcheck() {
  COMMAND="lotus mpool pending --local"
  TEXT="Lotus mpool backlog check"
  runcommand "$COMMAND" "$TEXT"
}

function sectorscheck() {
  COMMAND="lotus-miner sectors list -t -u"
  TEXT="Sectors not Available or Proving"
  runcommand "$COMMAND" "$TEXT"
}

function zfscheck(){
  COMMAND="zpool status fil ; zfs list -t snapshot; zfs get compressratio fil"
  TEXT="ZFS pool and snapshot status"
  runcommand "$COMMAND" "$TEXT"
}

function wpostcheck(){
  COMMAND="lotus-miner proving faults"
  TEXT="WindowPost Faulted Sectors"
  runcommand "$COMMAND" "$TEXT"
}

function walletcheck() {
  COMMAND="lotus wallet list"
  TEXT="Lotus Wallets Listing"
  runcommand "$COMMAND" "$TEXT"
}

function dailyreport(){
  diskcheck
}

function allchecks(){
  wpostcheck
  diskcheck
  zfscheck
  mpoolcheck
  sectorscheck
  walletcheck
}

function wpostalert() {
  ALERT_TYPE="cron.alert.faults"
  ALERT_DESC="WindowPost Faults"
  #0 = no alert, 1 or greater = alert
  ALERT_STATUS="$(lotus-miner proving faults | tail -n+3 | wc -l)"
  DIAGNOSTICS="lotus-miner proving faults"

  runalert "$ALERT_TYPE" "$ALERT_DESC" "$ALERT_STATUS" "$DIAGNOSTICS"
}

function nodealert() {
  ALERT_TYPE="cron.alert.node"
  ALERT_DESC="Node $HOSTNAME Offline"
  ALERT_STATUS=0
  DIAGNOSTICS="ll $LOCKFILE"
  if [ ! -f "$LOCKFILE" ]; then
    ALERT_STATUS=1
  fi
  runalert "$ALERT_TYPE" "$ALERT_DESC" "$ALERT_STATUS" "$DIAGNOSTICS"
}

function rootdiskalert() {
  anydiskalert $ROOTDISK "cron.alert.rootdisk" 15
}

function alldisksalert(){
  rootdiskalert
  if [ "$DISKALT1" ]; then
    anydiskalert $DISKALT1 "cron.alert.diskalt1" $DISKALT1PERC
  fi
  if [ "$DISKALT2" ]; then
    anydiskalert $DISKALT2 "cron.alert.diskalt2" $DISKALT2PERC
  fi
}

function anydiskalert(){
  THISDISK="$1"
  ALERT_TYPE=$2
  PERCENT=$3
  ALERT_DESC="$HOSTNAME $THISDISK usage more than $PERCENT %"
  ALERT_STATUS=0
  DIAGNOSTICS="df -h"
  DISKUSED="$(df --output=pcent,source | grep $THISDISK | cut -c1-3)"
  if [ $DISKUSED -gt $PERCENT ]; then
    ALERT_STATUS=1
  fi
  runalert "$ALERT_TYPE" "$ALERT_DESC" "$ALERT_STATUS" "$DIAGNOSTICS"
}

function emailer() {
  CURRENT_SUBJECT=$1
  TEXTFILE=$2
  mail -s "$CURRENT_SUBJECT" -r "$BOT_EMAIL" "$TEAM_EMAIL" < "$TEXTFILE"
}

function runalert() {
  # don't send emails by default
  SEND_EMAIL=0

  ALERT_CACHE="/tmp"
  ALERT_TYPE=$1
  ALERT_FILE="$ALERT_CACHE/$ALERT_TYPE"
  ALERT_DESC=$2
  ALERT_STATUS=$3
  DIAGNOSTICS=$4

  echo "Running runalert..." >> $LOG
  echo "Running $ALERT_DESC..." >> $LOG

  if [ "$ALERT_STATUS" -gt "0" ]; then
    if [ -f "$ALERT_FILE" ]; then
      echo "alert already detected." >> $LOG
    else
      NEW_ALERT=1
      touch $ALERT_FILE
      SUBJECT="ALERT: $ALERT_DESC"
      echo "$SUBJECT" >> $LOG
      echo "Running diagnostics: $DIAGNOSTICS" >> $LOG
      eval $DIAGNOSTICS >> $LOG
    fi
  else
    echo "No alert detected" >> $LOG
    if [ -f "$ALERT_FILE" ]; then
      SUBJECT="ALERT CLEARED: $ALERT_DESC"
      echo "Removing alert flag..." >> $LOG
      rm "$ALERT_FILE"
      NEW_ALERT=1
    else
      echo "No alert file found, all is well..." >> $LOG
    fi
  fi

  # check if an alert was found in any alert run
  if [ "$NEW_ALERT" -gt "0" ]; then
    SEND_EMAIL=1
  fi

  echo "Ending runalert..." >> $LOG
}

function runcommand() {
  COMMAND=$1
  TEXT=$2
  echo "-------" >> $LOG
  echo "Running: $2" >> $LOG
  echo "Using: $COMMAND" >> $LOG
  eval $COMMAND >> $LOG
  echo "$2 Complete..." >> $LOG
  echo "-------" >> $LOG
}

function printhelp() {
  echo "Options: "
  for OPTION in ${OPTIONS[@]}; do
    printf "$OPTION \n"
  done
}

main $1