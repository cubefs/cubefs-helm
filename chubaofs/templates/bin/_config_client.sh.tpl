#!/bin/bash

set -ex
export LC_ALL=C

echo "before prepare config..."

jq -n \
  --arg volName "$CBFS_CLIENT_VOL_NAME" \
  --arg owner "$CBFS_CLIENT_OWNER" \
  --arg logLevel "$CBFS_CLIENT_LOG_LEVEL" \
  --arg masterAddr "$CBFS_MASTER_ADDRS" \
  --arg exporterPort "$CBFS_CLIENT_EXPORTER_PORT" \
  --arg prof "$CBFS_CLIENT_PROF" \
  --arg consulAddr "$CBFS_CONSUL_ADDR" \
  '{
  "mountPoint": "/mnt/chubaofs",
  "volName": $volName,
  "owner": $owner,
  "masterAddr": $masterAddr,
  "logDir": "/chubaofs/logs",
  "logLevel": $logLevel,
  "consulAddr": $consulAddr,
  "exporterPort": $exporterPort,
  "profPort": $prof
}' > /chubaofs/conf/fuse.json

cat /chubaofs/conf/fuse.json
echo "after prepare config"

