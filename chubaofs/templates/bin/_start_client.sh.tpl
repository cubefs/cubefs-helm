#!/bin/bash

set -ex
export LC_ALL=C

mkdir -p /cfs/mnt

cat /cfs/conf/fuse.json
echo "start client"
/cfs/bin/cfs-client -f -c /cfs/conf/fuse.json