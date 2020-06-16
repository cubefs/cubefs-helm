#!/bin/bash

# set -ex
GET_CLUSTER_URL="http://$CBFS_MASTER_SERVICE_PORT/admin/getCluster"
code=1
while ((code!=0))
do
  clusterInfo=`curl -s "$GET_CLUSTER_URL" || echo ""`
  if [ "X"$clusterInfo == "X" ]; then
    code=1
    echo "waiting master service"
    sleep 5s
  else
    echo $clusterInfo | jq "."
    code=$( echo "$clusterInfo" | jq ".code" )
  fi
done
echo "master service is ok"
