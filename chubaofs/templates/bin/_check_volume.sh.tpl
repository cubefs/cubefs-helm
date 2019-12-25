#!/bin/bash

set -ex
GET_CLUSTER_URL="http://$CBFS_MASTER_SERVICE:$CBFS_MASTER_PORT/admin/getCluster"
CREATE_VOL_URL="http://$CBFS_MASTER_SERVICE:$CBFS_MASTER_PORT/admin/createVol?name=$CBFS_CLIENT_VOL_NAME&capacity=20&owner=$CBFS_CLIENT_OWNER&mpCount=3"
SERVICE_NOT_UNAVAILABLE=99999

function err_exit {
  echo "unknown exception"
  exit 1
}

function check_status() {
    node="$1"
    up=0
    echo -n "check $node "
    for i in $(seq 1 200) ; do
        clusterInfo=$(curl -s "$GET_CLUSTER_URL")
        NodeTotoalGB=$( echo "$clusterInfo" | jq ".data.${node}StatInfo.TotalGB" )
        if [[ $NodeTotoalGB -gt 0 ]]  ; then
            up=1
            break
        fi
        echo -n "."
        sleep 2
    done
    if [ $up -eq 0 ] ; then
        echo -n "timeout, exit"
        curl "$GET_CLUSTER_URL" | jq
        exit 2
    fi
    echo "ok"
}

function create_vol {
#  curl -v "http://10.196.30.231:8080/admin/createVol?name=test&capacity=10&owner=cfs&mpCount=3"
# {"code":1,"msg":"action[createVol], clusterID[test] name:test, err:action[doCreateVol], clusterID[test] name:test, err:duplicate vol  ","data":null}
# {"code":0,"msg":"success","data":"create vol[test] successfully, has allocate [10] data partitions"}
  create_result=$(curl $CREATE_VOL_URL)
  test -z $create_result && echo SERVICE_NOT_UNAVAILABLE || echo $create_result | jq .code
}

function start_check {
  sleep 15 
  check_status "MetaNode"
  check_status "DataNode"

  create_status=$(create_vol)
  if [[ "X"$create_status == "X"0 || "X"$create_status == "X"1 ]];then
    echo "Success"
  else
    err_exit
  fi
}

until nslookup $CBFS_MASTER_SERVICE; do echo waiting for $CBFS_MASTER_SERVICE;sleep 2;done;
start_check








