#!/bin/bash
# set -ex

mkdir -p /cfs/data/datanode/raft
cat /cfs/conf/datanode.json
echo "start master"
exec /cfs/bin/cfs-server -f {{ if .Values.log.do_not_redirect_std -}} -redirect-std=false {{- end }} -c /cfs/conf/datanode.json
