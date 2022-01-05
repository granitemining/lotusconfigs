# Usage: cgcreatesh(name, index)
# Called it cgcreatesh to distinguish it from bin cgcreate
function cgcreatesh() {
  cgname=$1
  cgindex=$2
  cgexists=$(lscgroup cpuset:$cgname | wc -c)

  if [[ "$cgexists" == 0 ]] ; then
    echo "Creating cgroup $cgname."
    let cpu=$cgindex-1
    if sudo cgcreate -a filuser:fil -t filuser:fil -g cpuset:$cgname ; then
      cgset -r cpuset.cpus=$cpu $cgname
      cgset -r cpuset.mems=0 $cgname
      echo "Finished creating cgroup $cgname."
    else
      echo "Failed to create cpuset:$cgname. Quitting..."
      return 1
    fi
  fi

  return 0
}

# Usage: repocreate(name)
function repocreate() {
  echo "Creating repo $1."
  repo="/fil/calibnet/lotusworkers/$1"
  repoexists=$(ls -A $repo | wc -c)
  if [[ "$repoexists" == 0 ]] ; then
    mkdir -p $repo
    if sudo mount --options size=4G -t tmpfs none $repo ; then
      sudo chown -R filuser:fil $repo
      echo "Finished creating repo at $repo"
    else
      echo "Failed to mount ramdisk at $repo. Quitting..."
      return 1
    fi
  fi

  return 0
}

# Usage: getindex(token)
function getindex() {
  index=1
  for d in /fil/calibnet/lotusworkers/$1*; do
    if [[ -d "$d" ]] && [[ ! -a "$d/.inuse" ]] ; then
      break
    fi
    ((index++))
  done

  return $index
}
