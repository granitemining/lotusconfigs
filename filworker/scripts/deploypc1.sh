#!/usr/bin/env bash
#set -x
#trap read debug

# Create pc1 cgroup
cgroupindex=1
for f in /fil/calibnet/lotusworkers/pc1*; do
  if [[ -d "$f" ]] && [[ ! -a "$f/.inuse" ]] ; then 
    break
  fi
  ((cgroupindex++))
done

cgroup="pc1w$cgroupindex"

# Create pc1 repo
echo "Creating repo $cgroup."
repo="/fil/calibnet/lotusworkers/$cgroup"
repoexists=$(ls -A $repo | wc -c)
if [[ "$repoexists" == 0 ]] ; then
  mkdir -p $repo
  if sudo mount --options size=4G -t tmpfs none $repo ; then
    sudo chown -R filuser:fil $repo
    echo "Finished creating repo at $repo"
  else
    echo "Failed to mount ramdisk at $repo. Quitting..."
    exit 1
  fi
fi

# Create pc1 cgroup
cgroupexists=$(lscgroup cpuset:$cgroup | wc -c)
if [[ "$cgroupexists" == 0 ]] ; then
  echo "Creating cgroup $cgroup."
  let cpu=$cgroupindex-1
  if sudo cgcreate -a filuser:fil -t filuser:fil -g cpuset:$cgroup ; then
    cgset -r cpuset.cpus=$cpu $cgroup
    cgset -r cpuset.mems=0 $cgroup
    echo "Finished creating cgroup $cgroup."
  else
    echo "Failed to create cpuset:$cgroup. Quitting..."
    exit 1
  fi
fi

# Fit environment
source ../.pc1.env

# Deploy pc1 worker
let port=3400+$cgroupindex
listen="10.0.0.243:$port"
if cgexec -g cpuset:$cgroup --sticky nohup lotus-worker --worker-repo=$repo run --listen=$listen --precommit2=false --commit=false --timeout=0 > $repo/$cgroup.log 2>&1 & ; then
  lotus-worker --worker-repo=$repo storage attach --seal /fil/sealing
  lotus-worker --worker-repo=$repo info
  touch $repo/.inuse
else
  echo "Failed to start $cgroup. Quitting..."
  exit 1
fi

exit 0
