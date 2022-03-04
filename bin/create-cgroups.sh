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
  echo "See https://en.wikipedia.org/wiki/Epyc#Second_generation_Epyc_(Rome)"
  read -p "How many CPUs? >"                    -i $cpus -e cpus
  read -p "How many core complexes per CPU? >"  -i $ccxspercpu -e ccxspercpu
  read -p "How many cores per complex? >"       -i $coresperccx -e coresperccx
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

let allccxs=$hyperthreads*$cpus*$ccxspercpu
let allcores=$allccxs*$coresperccx

tmpfile=$(mktemp /tmp/cgconfig.XXXXXX.conf)
cgname='all'

cpuinfo="0-$(expr $allcores - 1)"
if [ $(expr $allcores - 1) -eq 0 ]; then
  cpuinfo="0"
fi

meminfo=0
# meminfo="0-$(expr $allcores - 1)"
# if [ $(expr $allcores - 1) -eq 0 ]; then
#   meminfo="0"
# fi

generatecgdef "$cgname" "$uid" "$gid" "$cpuinfo" "$meminfo" "$tmpfile"
for (( ccx=0; ccx<$allccxs; ccx++ ))
do
  let cpulowerbound=$ccx*$coresperccx
  let cpuupperbound=$cpulowerbound+$coresperccx-1

  cgccxname="$cgname/ccx$ccx"
  cpuinfo="$cpulowerbound-$cpuupperbound"

  generatecgdef "$cgccxname" "$uid" "$gid" "$cpuinfo" "$meminfo" "$tmpfile"
  for (( core=$cpulowerbound; core<=$cpuupperbound; core++ ))
  do
    cgcorename="$cgccxname/c$core"
    generatecgdef "$cgcorename" "$uid" "$gid" "$core" "$meminfo" "$tmpfile"
  done
done

read -p "Create these cgroups? [y/n] >" -r create
if [[ "$create" == "y" ]] ; then
    sudo cgconfigparser -l $tmpfile
fi

rm $tmpfile
