#!/bin/bash

# set -ex
# source init_dirs.sh
echo "prepare to create configuration file"

jq -n \
  --arg port "$CBFS_METANODE_PORT" \
  --arg prof "$CBFS_METANODE_PROF" \
  --arg localIP "$CBFS_METANODE_LOCALIP" \
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
     "localIP": $localIP,
     "logLevel": $logLevel,
     "metadataDir": "/cfs/data",
     "logDir": "/cfs/logs",
     "raftDir": "/cfs/data/metanode/raft",
     "raftHeartbeatPort": $raftHeartbeatPort,
     "raftReplicaPort": $raftReplicaPort,
     "consulAddr": $consulAddr,
     "exporterPort": $exporterPort,
     "totalMem": $totalMem,
     "masterAddr": $masterAddrs
 }' | jq '.masterAddr |= split(",")' > /cfs/conf/metanode.json

cat /cfs/conf/metanode.json
echo "configuration finished"



