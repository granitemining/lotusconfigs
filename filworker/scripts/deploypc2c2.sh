#!/usr/bin/bash env
set -x
trap read debug
source .utils.sh

# Get pc2c2 index
getindex 'pc2c2'
windex=$?

# Create pc2c2 repo
wname="pc2c2w$windex"
repocreate $wname
wrepo=$?

source ../.pc2c2.env
let port=3500+$windex
listen="10.0.0.243:$port"
if nohup lotus-worker --worker-repo=$wrepo run --listen=$listen --addpiece=false --precommit1=false --unseal=false --timeout=0 > $wrepo/$wname.log 2>&1 & ; then
  lotus-worker --worker-repo=$wrepo storage attach --seal /fil/sealing
  lotus-worker --worker-repo=$wrepo info
  touch $wrepo/.inuse
else
  echo "Failed to start $wname. Quitting..."
  exit 1
fi

exit 0
