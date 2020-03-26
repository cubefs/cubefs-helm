#!/bin/bash

# set -ex
# source init_dirs.sh
echo "prepare to create configuration file"
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
  --arg metaNodeReservedMem "$CBFS_METANODE_RESERVED_MEM" \
  '{
    "role": "master",
    "ip": $ip,
    "listen": $port,
    "prof": $prof,
    "id": $id,
    "peers": $peers,
    "retainLogs": $retainLogs,
    "logDir": "/cfs/logs",
    "logLevel": $logLevel,
    "walDir": "/cfs/data/master/raft",
    "storeDir": "/cfs/data/master/rocksdbstore",
    "consulAddr": $consulAddr,
    "exporterPort": $exporterPort,
    "clusterName": $clusterName,
    "metaNodeReservedMem": $metaNodeReservedMem 
}' > /cfs/conf/master.json

cat /cfs/conf/master.json
echo "configuration finished"
