#!/bin/sh

RootPath=$(cd "$(dirname $0)";pwd)
CfsVersion="2.0.0"
if [[ -n "$1" ]] ;then
        # docker image tag of ChubaoFS
    CfsVersion=$1
fi

test -e ${RootPath}/bin/cfs-client && return
test -e ${RootPath}/bin/cfs-server && return
test -d ${RootPath}/chubaofs && rm -rf ${RootPath}/chubaofs
git clone https://github.com/chubaofs/chubaofs.git ${RootPath}/chubaofs && cd ${RootPath}/chubaofs && git checkout v${CfsVersion}
ChubaoFSSrcPath=${RootPath}/chubaofs
Out=`docker run -it --rm --privileged -v ${ChubaoFSSrcPath}:/root/go/src/github.com/chubaofs/chubaofs chubaofs/cfs-base:1.0.1 \
     /bin/bash -c 'cd /root/go/src/github.com/chubaofs/chubaofs/build && bash ./build.sh > build.out 2>&1 && echo 0 || echo 1'`
if [[ "X${Out:0:1}" != "X0" ]]; then
	echo "build cfs-server&cfs-client fail"
    exit 1	
fi

test -d ${RootPath}/bin || mkdir -p ${RootPath}/bin
test -e ${RootPath}/bin/cfs-client && rm ${RootPath}/bin/cfs-client
test -e ${RootPath}/bin/cfs-server && rm ${RootPath}/bin/cfs-server
mv ${ChubaoFSSrcPath}/build/bin/cfs-client ${RootPath}/bin
mv ${ChubaoFSSrcPath}/build/bin/cfs-server ${RootPath}/bin
rm -rf ${RootPath}/chubaofs
echo "build cfs-server&cfs-client success"


