#!/bin/bash
# set -ex

mkdir -p /cfs/data/master/raft
mkdir -p /cfs/data/master/rocksdbstore

cat /cfs/conf/master.json
echo "start master"
exec /cfs/bin/cfs-server -f {{ if .Values.log.do_not_redirect_std -}} -redirect-std=false {{- end }} -c /cfs/conf/master.json