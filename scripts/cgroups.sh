#!/usr/bin/bash

CGROUP_LOGLEVEL=DEBUG

# Create pc1 cgroups
for (( cgroup=1; cgroup<=16; cgroup++ ))
do
	let cpu=$cgroup-1
	let mem=0
	cgcreate -a filuser:fil -t filuser:fil -g cpuset:pc1w$cgroup
	cgset -r cpuset.cpus=$cpu pc1w$cgroup
	cgset -r cpuset.mems=$mem pc1w$cgroup
	echo "Created cgroup pc1w$cgroup!"
done
