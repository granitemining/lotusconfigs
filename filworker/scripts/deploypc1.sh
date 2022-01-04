#!/usr/bin/env bash
#trap "set +x; sleep 5; set -x" DEBUG
set -x
trap read debug

# Create pc1 cgroup
cgroupindex=1
for f in /fil/calibnet/lotusworkers/pc1*; do
  if [[ -d "$f" ]] && [[ -e "$f/.inuse"]]; then
    break
  fi
  ((cgroupindex++))
done

cgroup="pc1w$cgroupindex"

# Create pc1 repo
echo "Creating repo $cgroup."
repo="/fil/calibnet/lotusworkers/$cgroup"
mkdir -p $repo
sudo mount --options size=4G -t tmpfs none $repo
sudo chown -R filuser:fil $repo
echo "Finished creating repo $cgroup."

# Create pc1 cgroup
if [[ $(lscgroup cpuset:$cgroup) -ne 0 ]]; then
  echo "Creating cgroup $cgroup."
  let cpu=$i-1
  let mem=0
  sudo cgcreate -a filuser:fil -t filuser:fil -g cpuset:$cgroup
  cgset -r cpuset.cpus=$cpu cpuset:$cgroup
  cgset -r cpuset.mems=$mem cpuset:$cgroup
  echo "Finished creating cgroup $cgroup."
fi

# Fit environment
source ../.pc1.env

# Deploy pc1 worker
let port=3400+$i
listen="10.0.0.243:$port"
cgexec -g cpuset:$cgroup --sticky nohup lotus-worker --worker-repo=$repo run --listen=$listen --precommit2=false --commit=false --timeout=0 > $repo/$cgroup.log 2>&1 &
lotus-worker --worker-repo=$repo storage attach --seal /fil/sealing
lotus-worker --worker-repo=$repo info
touch $repo/.inuse
