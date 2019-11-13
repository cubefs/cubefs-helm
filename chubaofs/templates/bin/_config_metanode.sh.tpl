#!/bin/bash

set -ex
export LC_ALL=C

# source init_dirs.sh
echo "before prepare config..."

jq -n \
  --arg port "$CBFS_METANODE_PORT" \
  --arg prof "$CBFS_METANODE_PROF" \
  --arg logLevel "$CBFS_METANODE_LOG_LEVEL" \
  --arg raftHeartbeatPort "$CBFS_METANODE_RAFT_HEARTBEAT_PORT" \
  --arg raftReplicaPort "$CBFS_METANODE_RAFT_REPLICA_PORT" \
  --arg exporterPort "$CBFS_METANODE_EXPORTER_PORT" \
  --arg masterAddrs "$CBFS_MASTER_ADDRS" \
  --arg totalMem "$CBFS_MASTER_TOTAL_MEM" \
  --arg consulAddr "$CBFS_CONSUL_ADDR" \
    '{
     "role": "metanode",
     "listen": $port,
     "prof": $prof,
     "logLevel": $logLevel,
     "metadataDir": "/chubaofs/data",
     "logDir": "/chubaofs/logs",
     "raftDir": "/chubaofs/data/metanode/raft",
     "raftHeartbeatPort": $raftHeartbeatPort,
     "raftReplicaPort": $raftReplicaPort,
     "consulAddr": $consulAddr,
     "exporterPort": $exporterPort,
     "totalMem": $totalMem,
     "masterAddrs": $masterAddrs
 }' | jq '.masterAddrs |= split(",")' > /chubaofs/conf/metanode.json

cat /chubaofs/conf/metanode.json
echo "after prepare config"



