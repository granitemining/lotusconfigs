#!/usr/bin/env bash
#trap "set +x; sleep 5; set -x" DEBUG
set -x
trap read debug

# Create pc1 cgroup
let i=$(ls -f /fil/calibnet | grep -c pc1)+1
cgroup=pc1w$i

# Create pc1 cgroup
echo "Creating cgroup $cgroup."
let cpu=$i-1
let mem=0
sudo cgcreate -a filuser:fil -t filuser:fil -g cpuset:$cgroup
cgset -r cpuset.cpus=$cpu cpuset:$cgroup
cgset -r cpuset.mems=$mem cpuset:$cgroup
echo "Finished creating cgroup $cgroup."

# Create pc1 repo
echo "Creating repo $cgroup."
repo="/fil/calibnet/$cgroup"
mkdir $repo
echo "Finished creating repo $cgroup."

let port=3400+$i
listen="10.0.0.243:$port"
cgexec -g cpuset:$cgroup --sticky nohup lotus-worker --worker-repo=$repo run --listen=$listen --precommit2=false --commit=false --timeout=0 > $repo/$cgroup.log 2>&1 &
lotus-worker --worker-repo=$repo storage attach --seal /fil/sealing
lotus-worker --worker-repo=$repo info
