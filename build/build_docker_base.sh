#!/usr/bin/env bash

Version="1.0.1"
if [[ -n "$1" ]] ;then
        # docker image tag of Cubefs
    Version=$1
fi

RootPath=$(cd $(dirname $0); pwd)
CfsBase="cubefs/cfs-base:$Version"
docker build -t ${CfsBase} --network host -f ${RootPath}/Dockerfile-base ${RootPath}
