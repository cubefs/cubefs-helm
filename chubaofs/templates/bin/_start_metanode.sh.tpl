#!/bin/bash
set -ex
export LC_ALL=C

mkdir -p /chubaofs/data/metanode/raft

cat /chubaofs/conf/metanode.json
echo "start master"
/chubaofs/bin/cfs-server -f -c /chubaofs/conf/metanode.json