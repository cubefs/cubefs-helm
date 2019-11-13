#!/bin/bash

set -ex
VOL_STAT_URL="http://$CBFS_MASTER_SERVICE:$CBFS_MASTER_PORT/client/volStat?name=$CBFS_CLIENT_VOL_NAME"
CREATE_VOL_URL="http://$CBFS_MASTER_SERVICE:$CBFS_MASTER_PORT/admin/createVol?name=$CBFS_CLIENT_VOL_NAME&capacity=20&owner=$CBFS_CLIENT_OWNER&mpCount=3"
SERVICE_NOT_UNAVAILABLE=99999
VOL_NOT_EXIST=7
VOL_EXIST=0

function err_exit {
  echo "unknown exception"
  exit 1
}

function check_vol_status {
# {"code":0,"msg":"success","data":{"Name":"test","TotalSize":107374182400,"UsedSize":4096}}
# {"code":7,"msg":"vol not exists","data":null}
  status_result=$(curl $VOL_STAT_URL)
  test -z $status_result && echo SERVICE_NOT_UNAVAILABLE || echo $status_result | jq .code
}

function create_vol {
#  curl -v "http://10.196.30.231:8080/admin/createVol?name=test&capacity=10&owner=cfs&mpCount=3"
# {"code":1,"msg":"action[createVol], clusterID[test] name:test, err:action[doCreateVol], clusterID[test] name:test, err:duplicate vol  ","data":null}
# {"code":0,"msg":"success","data":"create vol[test] successfully, has allocate [10] data partitions"}
  create_result=$(curl $CREATE_VOL_URL)
  test -z $create_result && echo SERVICE_NOT_UNAVAILABLE || echo $create_result | jq .code
}

function start_check {
  status=$SERVICE_NOT_UNAVAILABLE
  while [ "X"$status == "X"$SERVICE_NOT_UNAVAILABLE ]
  do 
    status=$(check_vol_status)
    echo "--status:$status"
    sleep 2
  done

  echo "status:$status"
  if [[ "X"$status == "X$VOL_EXIST" ]];then
   	echo "Success"
  elif [[ "X"$status == "X$VOL_NOT_EXIST" ]]; then
  	create_status=$(create_vol)
  	if [[ "X"$create_status == "X"0 || "X"$create_status == "X"1 ]];then
  		echo "Success"
  	else
  	  err_exit
  	fi
  else
	  err_exit
  fi
}

sleep 120
until nslookup $CBFS_MASTER_SERVICE; do echo waiting for $CBFS_MASTER_SERVICE;sleep 2;done;
start_check







