#!/usr/bin/env bash
#set -x
#trap read debug

source .utils.sh

# Get pc1 index
getindex 'pc1'
windex=$?

# Create pc1 repo
wname="pc1w$index"
repocreate $wname
wrepo=$?

cgcreatesh $wname $index
source ../.pc1.env
let port=3400+$windex
listen="10.0.0.243:$port"
if cgexec -g cpuset:$wname --sticky nohup lotus-worker --worker-repo=$wrepo run --listen=$listen --precommit2=false --commit=false --timeout=0 > $wrepo/$wname.log 2>&1 & ; then
  lotus-worker --worker-repo=$wrepo storage attach --seal /fil/sealing
  lotus-worker --worker-repo=$wrepo info
  touch $wrepo/.inuse
else
  echo "Failed to start $wname. Quitting..."
  exit 1
fi

exit 0
