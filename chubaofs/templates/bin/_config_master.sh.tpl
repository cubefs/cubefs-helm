#!/bin/bash

set -ex
export LC_ALL=C

# source init_dirs.sh
echo "before prepare config..."
CBFS_HOSTNAME_INDEX=""
CBFS_ID=""
CBFS_HOSTNAME_INDEX=`echo $POD_NAME | awk -F '-' '{print $2}'`
CBFS_ID=$(($CBFS_HOSTNAME_INDEX+1))

jq -n \
  --arg clusterName "$CBFS_MASTER_CLUSTER" \
  --arg id $CBFS_ID \
  --arg ip "$POD_IP" \
  --arg port "$CBFS_MASTER_PORT" \
  --arg prof "$CBFS_MASTER_PROF" \
  --arg peers "$CBFS_MASTER_PEERS" \
  --arg retainLogs "$CBFS_MASTER_RETAIN_LOGS" \
  --arg exporterPort "$CBFS_MASTER_EXPORTER_PORT" \
  --arg logLevel "$CBFS_MASTER_LOG_LEVEL" \
  --arg consulAddr "$CBFS_CONSUL_ADDR" \
  '{
    "role": "master",
    "ip": $ip,
    "port": $port,
    "prof": $prof,
    "id": $id,
    "peers": $peers,
    "retainLogs": $retainLogs,
    "logDir": "/chubaofs/logs",
    "logLevel": $logLevel,
    "walDir": "/chubaofs/data/master/raft",
    "storeDir": "/chubaofs/data/master/rocksdbstore",
    "consulAddr": $consulAddr,
    "exporterPort": $exporterPort,
    "clusterName": $clusterName
}' > /chubaofs/conf/master.json

cat /chubaofs/conf/master.json
echo "after prepare config"
