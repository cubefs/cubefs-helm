#!/bin/bash
# set -ex

mkdir -p /cfs/data/metanode/raft

cat /cfs/conf/metanode.json
echo "start master"
exec /cfs/bin/cfs-server -f {{ if .Values.log.do_not_redirect_std -}} -redirect-std=false {{- end }} -c /cfs/conf/metanode.json