#!/bin/bash
set -ex
export LC_ALL=C

mkdir -p /cfs/data/datanode/raft
cat /cfs/conf/datanode.json
echo "start master"
/cfs/bin/cfs-server -f -c /cfs/conf/datanode.json
