#!/usr/bin/env bash

RootPath=$(cd $(dirname $0); pwd)
Version="2.0.0"
if [[ -n "$1" ]] ;then
        # docker image tag of ChubaoFS
    Version=$1
fi

# source ${RootPath}/build_cfs.sh $Version 
CfsServer="chubaofs/cfs-server:$Version"
CfsClient="chubaofs/cfs-client:$Version"
docker build -t ${CfsServer} --network host -f ${RootPath}/Dockerfile --target server ${RootPath}
docker build -t ${CfsClient} --network host -f ${RootPath}/Dockerfile --target client ${RootPath}
