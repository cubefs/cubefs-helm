#!/bin/bash

echo "prepare to create configuration file"

jq -n \
  --arg port "$CBFS_OBJECTNODE_PORT" \
  --arg logLevel "$CBFS_OBJECTNODE_LOG_LEVEL" \
  --arg masterAddr "$CBFS_MASTER_ADDR" \
  --arg objectNodeDomain "$OBJECT_NODE_DOMAIN" \
  --arg masterAddrs "$CBFS_MASTER_ADDRS" \
  --arg grafanaUrl "http://$CBFS_GRAFANA_URL" \
  --arg clusterName "$CBFS_CLUSTER_NAME" \
  --arg prometheusAddr "$CBFS_PROMETHEUS_ADDR" \
    '{
  "role": "console",
  "logDir": "/cfs/log/",
  "logLevel": $logLevel,
  "listen": $port,
  "master_instance": $masterAddr,
  "objectNodeDomain": $objectNodeDomain,
  "masterAddr": $masterAddrs,
  "monitor_addr": $prometheusAddr,
  "dashboard_addr": $grafanaUrl,
  "monitor_app": "cfs",
  "monitor_cluster": $clusterName
}' | jq '.masterAddr |= split(",")' > /cfs/conf/console.json

cat /cfs/conf/console.json
echo "configuration finished"



