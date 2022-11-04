#!/bin/bash
# set -ex

cat /cfs/conf/objectnode.json
echo "start objectnode"
exec /cfs/bin/cfs-server -f {{ if .Values.log.do_not_redirect_std -}} -redirect-std=false {{- end }} -c /cfs/conf/objectnode.json
