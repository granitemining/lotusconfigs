#!/usr/bin/env bash

set -o braceexpand

while [[ "$correct" != "y" ]]
do
  read -p "How many core complexes? >" -i $ccxcount -e ccxcount
  read -p "How many cores per complex? >" -i $coresperccx -e coresperccx
  read -p "Which user will own the cgroups? >" -i $uid -e user
  read -p "Which group will own the cgroups? >" -i $gid -e group
  read -p "Is the above correct? [y/n] >" -e correct
done

let corecount=$ccxcount*$coresperccx-1
let ccxcount-- # Make ccxcount 0 based

tmpfile=$(mktemp /tmp/cgconfig.XXXXXX.conf)

cpus="0-$corecount"
mems="0-1"
echo "group all { perm { task { uid = $uid; gid = $gid; } admin { uid = $uid; gid = $gid; } } cpuset { cpuset.cpus = 0-$corecount; cpuset.mems = 0-1; } }" >> $tmpfile
mycgconfig="all :: cpus = $cpus & mems = $mems"

for $iccx in {0..$ccxcount}
do
    cg="all/ccx$iccx"
    let cpulowerbound=$iccx*$coresperccx
    let cpuupperbound=$cpulowerbound+2
    cpus="$cpulowerbound-$cpuupperbound"
    let mems=$corecount/$cpulowerbound
    echo "group $cg { perm { task { uid = $uid; gid = $gid; } admin { uid = $uid; gid = $gid; } } cpuset { cpuset.cpus = $cpus; cpuset.mems = $mems; } }" >> $tmpfile
    mycgconfig="$mycgconfig\n$cg :: cpus = $cpus & mems = $mems"

    for $icore in {$cpulowerbound..$cpuupperbound}
    do
        cg="$cg/c$icore"
        echo "group $cg { perm { task { uid = $uid; gid = $gid; } admin { uid = $uid; gid = $gid; } } cpuset { cpuset.cpus = $icore; cpuset.mems = $mems; } }" >> $tmpfile
        mycgconfig="$mycgconfig\n$cg :: cpus = $cpus & mems = $mems"
    done
done

echo $mycgconfig

read -p "Create these cgroups? [y/n] >" -r create
if [[ "$create" == "y" ]] ; then
    cgconfigparser -l $tmpfile
done
