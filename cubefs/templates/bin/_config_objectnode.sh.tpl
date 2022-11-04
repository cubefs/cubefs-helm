#!/bin/bash

# set -ex
# source init_dirs.sh
echo "prepare to create configuration file"

jq -n \
  --arg port "$CBFS_OBJECTNODE_PORT" \
  --arg prof "$CBFS_OBJECTNODE_PROF" \
  --arg logLevel "$CBFS_OBJECTNODE_LOG_LEVEL" \
  --arg exporterPort "$CBFS_OBJECTNODE_EXPORTER_PORT" \
  --arg masterAddrs "$CBFS_MASTER_ADDRS" \
  --arg domains "$CBFS_OBJECTNODE_DOMAINS" \
  --arg region "$CBFS_OBJECTNODE_REGION" \
    '{
     "role": "objectnode",
     "listen": $port,
     "prof": $prof,
     "logLevel": $logLevel,
     "logDir": "/cfs/logs",
     "exporterPort": $exporterPort,
     "domains": $domains,
     "region": $region,
     "masterAddr": $masterAddrs
 }' | jq '.masterAddr |= split(",")' | jq '.domains |= split(",")' > /cfs/conf/objectnode.json

cat /cfs/conf/objectnode.json
echo "configuration finished"



