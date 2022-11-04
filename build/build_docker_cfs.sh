#!/usr/bin/env bash

RootPath=$(cd $(dirname $0); pwd)
Version="0.0.1"
if [[ -n "$1" ]] ;then
        # docker image tag of Cubefs
    Version=$1
fi

# source ${RootPath}/build_cfs.sh $Version 
CfsServer="cubefs/cfs-server:$Version"
CfsClient="cubefs/cfs-client:$Version"
docker build -t ${CfsServer} --network host -f ${RootPath}/Dockerfile --target server ${RootPath}
docker build -t ${CfsClient} --network host -f ${RootPath}/Dockerfile --target client ${RootPath}
