#!/bin/bash
# set -ex

mkdir -p /cfs/data/metanode/raft

cat /cfs/conf/metanode.json
echo "start master"
/cfs/bin/cfs-server -f -c /cfs/conf/metanode.json