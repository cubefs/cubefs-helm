#!/bin/bash
# set -ex

mkdir -p /cfs/data/datanode/raft
cat /cfs/conf/datanode.json
echo "start master"
/cfs/bin/cfs-server -f -c /cfs/conf/datanode.json
