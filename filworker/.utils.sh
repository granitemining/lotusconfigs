# Usage: .prunewrepos
function .prunewrepos()
{
  find /fil/calibnet/lotusworkers/ -type d -empty -delete
}

# Usage: .createwrepo wreponame
function .createwrepo()
{
  wreponame="${1:-$(echo $RANDOM | md5sum | head -c 8)}"
  wrepopath="/fil/calibnet/lotusworker/$wreponame"

  mkdir -p $wrepopath
  sudo mount --options size=4G -t tmpfs none $wrepopath
  sudo chown -R filuser:fil $wrepopath

  echo $wrepopath
}

# Usage: .createwcgroup cpus mems wcgroupname
function .createwcgroup()
{
  wcgroupname="${3:-$(echo $RANDOM | md5sum | head -c 8)}"
  wcgrouppath="/sys/fs/cgroup/cpuset/$wcgroupname"
  
  sudo cgcreate -a filuser:fil -t filuser:fil -g cpuset:$wcgroupname
  cgset -r cpuset.cpus=$1 $wcgroupname
  cgset -r cpuset.mems=$2 $wcgroupname

  echo $wcgrouppath
}
