#!/bin/bash

set -ex
export LC_ALL=C

mkdir -p /mnt/chubaofs

cat /chubaofs/conf/fuse.json
echo "start client"
/chubaofs/bin/cfs-client -f -c /chubaofs/conf/fuse.json