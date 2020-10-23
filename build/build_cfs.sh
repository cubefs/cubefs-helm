#!/bin/bash

RootPath=$(cd "$(dirname $0)";pwd)

help() {
    cat <<EOF
Usage: ./build_cfs.sh [ -b | --build ] [ -bc | --build-with-clean ] 
    -h, --help              	show help info
    -b, --build             	build ChubaoFS server and client
    -rb, --rebuild              clean and download ChubaoFS source code, then build ChubaoFS server and client
EOF
    exit 0
}

function print() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

function clean() {
	test -d ${RootPath}/bin && rm -rf ${RootPath}/bin
	test -d ${RootPath}/chubaofs && rm -rf ${RootPath}/chubaofs
}

function clone {
	git clone https://github.com/chubaofs/chubaofs.git ${RootPath}/chubaofs
}


function compile() {
	test -d ${RootPath}/chubaofs && cd ${RootPath}/chubaofs || (print "chubaofs source code not exists"; exit 1)
	Out=`docker run -it --rm --privileged -v ${RootPath}/chubaofs:/root/go/src/github.com/chubaofs/chubaofs chubaofs/cfs-base:1.0.1 \
	    /bin/bash -c 'cd /root/go/src/github.com/chubaofs/chubaofs && make build > build/build.out 2>&1 && echo 0 || echo 1'`
	if [[ "X${Out:0:1}" != "X0" ]]; then
		print "build cfs-server&cfs-client fail"
		exit 1	
	fi

	mv ${RootPath}/chubaofs/build/bin ${RootPath}/
	print "build cfs-server&cfs-client success"
}

function build_with_clean() {
	clean
	clone
	compile
}

function build() {
	test -d ${RootPath}/bin && rm -rf ${RootPath}/bin
	compile
}

if [ $# == 0 ]; then
        help
        exit 1
fi

while [[ $# -ge 1 ]]; do
        case "$1" in
                -rb | --rebuild ) 
			build_with_clean
			shift 
			;;
                -b | --build ) 
			build
			shift 
			;;
                * ) 
			help
			shift 
			;;
        esac
done
