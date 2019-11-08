#!/bin/bash
set -ex
export LC_ALL=C

mkdir -p /chubaofs/data/master/raft
mkdir -p /chubaofs/data/master/rocksdbstore

cat /chubaofs/conf/master.json
echo "start master"
/chubaofs/bin/cfs-server -f -c /chubaofs/conf/master.json