#!/bin/bash
# set -ex

cat /cfs/conf/objectnode.json
echo "start objectnode"
/cfs/bin/cfs-server -f -c /cfs/conf/objectnode.json
