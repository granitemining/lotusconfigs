#!/usr/bin/bash

cgroup=1

# Create pc1 cgroups
while [cgroup <= 16]
do
echo "Creating cgroup pc1w$cgroup!"
cgroup++
done


# Create pc2c2 cgroups
while [cgroup <= 8]
do
echo "Creating cgroup pc2c2w$cgroup!"
cgroup++
done