#!/bin/bash
set -ex
export LC_ALL=C

mkdir -p /cfs/data/datanode/raft

n=0
DISK_DIR=""
arr=(${CBFS_DATANODE_DISKS//,/ })  
for i in ${arr[@]}; do   
  Dev=$(echo $i | awk -F ":" '{print $1}')
  Quaota=$(echo $i | awk -F ":" '{print $2}')
  MountDir="/data$n"
  Type=$(blkid -o value -s TYPE $Dev)
  if [ -z $Type ];then
    echo "device[$Dev] not exist"
    continne
  fi
  
  test -e $MountDir || mkdir $MountDir
  mount $Dev $MountDir
  n=$(($n+1))
done

cat /cfs/conf/datanode.json
echo "start master"
/cfs/bin/cfs-server -f -c /cfs/conf/datanode.json