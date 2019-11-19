#!/bin/bash
set -ex
export LC_ALL=C

mkdir -p /cfs/data/metanode/raft

cat /cfs/conf/metanode.json
echo "start master"
/cfs/bin/cfs-server -f -c /cfs/conf/metanode.json