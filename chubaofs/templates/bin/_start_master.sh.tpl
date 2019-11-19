#!/bin/bash
set -ex
export LC_ALL=C

mkdir -p /cfs/data/master/raft
mkdir -p /cfs/data/master/rocksdbstore

cat /cfs/conf/master.json
echo "start master"
/cfs/bin/cfs-server -f -c /cfs/conf/master.json