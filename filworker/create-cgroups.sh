#!/usr/bin/env bash

# Usage: generatecgdef $cgname $uid $gid $cpus $mems $tmpfile 
function generatecgdef
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
case "$hyperthreading" in
  'y') hyperthreads=2 ;;
    *) hyperthreads=1 ;;
esac

let ccxtotal=$cpucount*$ccxcount*$hyperthreads
let coretotal=$ccxtotal*$ccxcorecount

tmpfile=$(mktemp /tmp/cgconfig.XXXXXX.conf)
cgname='all'
cpus="0-$(expr $coretotal - 1)"
mems="0-$(expr $memcount - 1)"
let memshalf=$coretotal/2

generatecgdef "$cgname" "$uid" "$gid" "$cpus" "$mems" "$tmpfile"
for (( iccx=0; iccx<$ccxtotal; iccx++ ))
do
    let cpulowerbound=$iccx*$ccxcorecount
    let cpuupperbound=$cpulowerbound+2

    cgccxname="$cgname/ccx$iccx"
    cpus="$cpulowerbound-$cpuupperbound"

    (( cpulowerbound < memshalf )) && mems=0 || mems=1
    generatecgdef "$cgccxname" "$uid" "$gid" "$cpus" "$mems" "$tmpfile"
    for (( icore=$cpulowerbound; icore<=$cpuupperbound; icore++ ))
    do
        cgcorename="$cgccxname/c$icore"
	generatecgdef "$cgcorename" "$uid" "$gid" "$icore" "$mems" "$tmpfile"
    done
done

read -p "Create these cgroups? [y/n] >" -r create
if [[ "$create" == "y" ]] ; then
    sudo cgconfigparser -l $tmpfile
fi

rm $tmpfile
