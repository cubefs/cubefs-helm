#!/bin/bash

# set -ex

mkdir -p /cfs/mnt

cat /cfs/conf/fuse.json
echo "start client"
/cfs/bin/cfs-client -f -c /cfs/conf/fuse.json