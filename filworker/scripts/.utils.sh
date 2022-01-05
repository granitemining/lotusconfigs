# Usage: createcg(name)
function createcg() {
  cgname=$1
  cgindex=$2
  cgexists=$(lscgroup cpuset:$cgname | wc -c)

  if [[ "$cgexists" == 0 ]] ; then
    let cpu=$cgindex-1
    sudo cgcreate -a filuser:fil -t filuser:fil -g cpuset:$cgname ; then
    cgset -r cpuset.cpus=$cpu $cgname
    cgset -r cpuset.mems=0 $cgname
  fi
}

# Usage: createrepo(reponame)
function createrepo() {
  reponame=$1
  repo="/fil/calibnet/lotusworkers/$reponame"
  mkdir -p $repo
  sudo mount --options size=4G -t tmpfs none $repo
  sudo chown -R filuser:fil $repo
}

# Usage: getreponame()
function getreponame() {
  reponame=$(echo $RANDOM | md5sum | head -c 8)
  for dir in /fil/calibnet/lotusworkers/*/; do
    if [[ ! -a "$dir/.inuse" ]] ; then
      reponame=${dir%*/}
      break
    fi
  done
  return $reponame
}

# Usage: getindex
function getindex() {
  index=0
  for dir in /fil/calibnet/lotusworkers/*/; do
    if [[ ! -a "$dir/.inuse" ]] ; then
      break
    fi
    ((index++))
  done
  return $index
}
