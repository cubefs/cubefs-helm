#!/bin/bash
set -ex
export LC_ALL=C

cat /cfs/conf/objectnode.json
echo "start objectnode"
/cfs/bin/cfs-server -f -c /cfs/conf/objectnode.json
