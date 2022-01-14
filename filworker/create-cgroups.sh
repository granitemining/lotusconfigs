#!/usr/bin/env bash

# Usage: .generatecgdef $cgname $uid $gid $cpus $mems $tmpfile 
function .generatecgdef()
{
    cat << EOT >> $6
    group $1 {
        perm {
            task {
                uid = $2;
                gid = $3;
            }
            admin {
                uid = $2;
                gid = $3;
            }
        }
        cpuset {
            cpuset.cpus = $4;
            cpuset.mems = $5;
        }
    }
EOT
    echo "$1 :: cpus = $4 & mems = $5"
}

while [[ "$correct" != "y" ]]
do
  read -p "How many CPUs? >"                    -i $cpucount -e cpucount
  read -p "How many core complexes per CPU? >"  -i $ccxcount -e ccxcount
  read -p "How many cores per complex? >"       -i $ccxcorecount -e ccxcorecount
  read -p "How many memory nodes >"             -i $memcount -e memcount
  read -p "Hyperthreading? [y/n] >"             -i $hyperthreading -e hyperthreading
  read -p "Which user will own the cgroups? >"  -i $uid -e uid
  read -p "Which group will own the cgroups? >" -i $gid -e gid
  read -p "Is the above correct? [y/n] >"       -e correct
done

# Double ccx count if hyperthreading is enabled
let hyperthreads=1
if [[ "$hyperthreading" == "y" ]] ; then
    let hyperthreads=2
fi

let ccxtotal=$cpucount*$ccxcount*$hyperthreads
let coretotal=$ccxtotal*$ccxcorecount

tmpfile=$(mktemp /tmp/cgconfig.XXXXXX.conf)
cgname='all'
cpus="0-$(expr $coretotal - 1)"
mems="0-$(expr $memcount - 1)"
let memshalf=$coretotal/2

.generatecgdef "$cgname" "$uid" "$gid" "$cpus" "$mems" "$tmpfile"

for (( iccx=0; iccx<$ccxtotal; iccx++ ))
do
    cgccxname="$cgname/ccx$iccx"
    let cpulowerbound=$iccx*$ccxcorecount
    let cpuupperbound=$cpulowerbound+2
    cpus="$cpulowerbound-$cpuupperbound"
    
    if (( cpulowerbound < memshalf )); then
	mems=0
    else
	mems=1
    fi

    .generatecgdef "$cgccxname" "$uid" "$gid" "$cpus" "$mems" "$tmpfile"
    for (( icore=$cpulowerbound; icore<=$cpuupperbound; icore++ ))
    do
        cgcorename="$cgccxname/c$icore"
	.generatecgdef "$cgcorename" "$uid" "$gid" "$icore" "$mems" "$tmpfile"
    done
done

read -p "Create these cgroups? [y/n] >" -r create
if [[ "$create" == "y" ]] ; then
    cgconfigparser -l $tmpfile
fi
