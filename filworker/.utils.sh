# Usage: .createwrepo wreponame
function .createwrepo()
{
  wreponame=$1
  wrepopath="/fil/sealing/$wreponame"

  mkdir -p $wrepopath

  echo $wrepopath
}

# Usage: .createwcgroup cpus mems wcgroupname
function .createwcgroup()
{
  cpus=$2
  mems=$3
  wcgroupname=$1
  if [ -z "$wcgroupname" ] ; then
    wcgroupname=$(echo $RANDOM | md5sum | head -c 8)
  fi

  wcgrouppath="/sys/fs/cgroup/cpuset/$wcgroupname"
  
  if [ ! -d "$wcgrouppath" ] ; then
    sudo cgcreate -a filuser:fil -t filuser:fil -g cpuset:$wcgroupname
    cgset -r cpuset.cpus=$cpus $wcgroupname
    cgset -r cpuset.mems=$mems $wcgroupname
  fi

  echo $wcgrouppath
}

# Usage: .sanitizebool $userinput
function .sanitizebool()
{
  userinput=$1
  converted='false'
  if [[ "$userinput" == "y" ]] ; then
    converted='true'
  fi

  echo $converted
}
