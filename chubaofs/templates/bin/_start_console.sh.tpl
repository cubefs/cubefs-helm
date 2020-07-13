#!/bin/bash
# set -ex

cat /cfs/conf/console.json
echo "start console"
/cfs/bin/cfs-server -f -c /cfs/conf/console.json
