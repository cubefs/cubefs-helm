#!/bin/bash

# set -ex

CBFS_CONFIG_PATH="/cfs/conf"
CBFS_BIN_SERVER="/cfs/bin/cfs-server"
CBFS_BIN_CLIENT="/cfs/bin/cfs-client"
CBFS_LOG_PATH="/cfs/logs"

ROLE_MASTER="master"
ROLE_METANODE="metanode"
ROLE_DATANODE="datanode"
ROLE_OBJECTNODE="objectnode"
ROLE_CLIENT="client"

help() {
    cat <<EOF

Usage: ./start.sh [ -h | --help ] [ component ]
    -h, --help						show help info
    $ROLE_MASTER						start ChubaoFS Master service
    $ROLE_DATANODE						start ChubaoFS DataNode service
    $ROLE_METANODE						start ChubaoFS MetaNode service
    $ROLE_OBJECTNODE						start ChubaoFS ObjectNode service
    $ROLE_CLIENT [masterAddr] [volName] [Owner]		start ChubaoFS Client service
    check [masterAddr]				check ChubaoFS Master service status
EOF
    exit 0
}

function print() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

function start_cfs_server() {
	local config_file_name=$1
	print_server_version
	test -r "$CBFS_CONFIG_PATH/$config_file_name.json" && cat "$CBFS_CONFIG_PATH/$config_file_name.json" || (print "file $CBFS_CONFIG_PATH/$config_file_name.json not found"; exit 1)
	$CBFS_BIN_SERVER -c $CBFS_CONFIG_PATH/$config_file_name.json
}

function start_cfs_client() {
	local config_file_name=$1
	print_client_version
	test -r "$CBFS_CONFIG_PATH/$config_file_name.json" && cat "$CBFS_CONFIG_PATH/$config_file_name.json" || (print "file $CBFS_CONFIG_PATH/$config_file_name.json not found"; exit 1)
	$CBFS_BIN_CLIENT -c $CBFS_CONFIG_PATH/$config_file_name.json
}

function print_server_version() {
	print "print cfs-server version"
	print "------"
	if [ -x $CBFS_BIN_SERVER ]; then
		$CBFS_BIN_SERVER -v 
		print "---"
	else
		print "not found $CBFS_BIN_SERVER"
		exit 1
	fi
}

function print_client_version() {
	print "print cfs-client version"
	print "------"
	if [ -x $CBFS_BIN_CLIENT ]; then
		$CBFS_BIN_CLIENT -v 
		print "---"
	else
		print "not found $CBFS_BIN_CLIENT"
		exit 1
	fi
}

function create_master_config() {
	if [ "X$POD_NAME" == "X" ]; then
		print "env POD_NAME not exist"
		exit 1
	fi

	if [ "X$POD_IP" == "X" ]; then
		print "env POD_IP not exist"
		exit 1
	fi

	if [ "X$CBFS_MASTER_PEERS" == "X" ]; then
		print "env CBFS_MASTER_PEERS not exist"
		exit 1
	fi

	CBFS_HOSTNAME_INDEX=""
	CBFS_ID=""
	CBFS_HOSTNAME_INDEX=`echo ${POD_NAME##*-}`
 	CBFS_ID=`expr ${CBFS_HOSTNAME_INDEX} + 1`
	local id=$CBFS_ID
	local local_ip=$POD_IP
	local cluster_name=${CBFS_CLUSTER_NAME:-mycluster}
	local port=${CBFS_PORT:-17110}
	local prof=${CBFS_PROF:-17120}
	local retain_logs=${CBFS_RETAIN_LOGS:-2000}
	local exporter_port=${CBFS_EXPORTER_PORT:-17150}
	local log_level=${CBFS_LOG_LEVEL:-error}
	local consul_addr=${CBFS_CONSUL_ADDR:-http://consul-service.chubaofs.svc.cluster.local:8500}
	local metanode_reserved_mem=${CBFS_METANODE_RESERVED_MEM:-67108864}

	jq -n \
	  --arg clusterName "$cluster_name" \
	  --arg id $id \
	  --arg ip "$local_ip" \
	  --arg port "$port" \
	  --arg prof "$prof" \
	  --arg peers "$CBFS_MASTER_PEERS" \
	  --arg retainLogs "$retain_logs" \
	  --arg exporterPort "$exporter_port" \
	  --arg logLevel "$log_level" \
	  --arg consulAddr "$consul_addr" \
	  --arg metaNodeReservedMem "$metanode_reserved_mem" \
	  '{
	    "role": "master",
	    "ip": $ip,
	    "listen": $port,
	    "prof": $prof,
	    "id": $id,
	    "peers": $peers,
	    "retainLogs": $retainLogs,
	    "logDir": "/cfs/logs",
	    "logLevel": $logLevel,
	    "walDir": "/cfs/data/master/raft",
	    "storeDir": "/cfs/data/master/rocksdbstore",
	    "consulAddr": $consulAddr,
	    "exporterPort": $exporterPort,
	    "clusterName": $clusterName,
	    "metaNodeReservedMem": $metaNodeReservedMem 
	}' > /cfs/conf/master.json
}

function create_metanode_config() {
	if [ 0$CBFS_MASTER_ADDRS == 0 ]; then
		print "env CBFS_MASTER_ADDRS not exist"
		exit 1
	fi

	local port=${CBFS_PORT:-17210}
	local prof=${CBFS_PROF:-17220}
	local log_level=${CBFS_LOG_LEVEL:-error}
	local raft_heartbeat_port=${CBFS_RAFT_HEARTBEAT_PORT:-17230}
	local raft_replica_port=${CBFS_RAFT_REPLICA_PORT:-17240}
	local exporter_port=${CBFS_EXPORTER_PORT:-17250}
	local total_mem=${CBFS_TOTAL_MEM:-1073741824}
	local consul_addr=${CBFS_CONSUL_ADDR:-http://consul-service.chubaofs.svc.cluster.local:8500}

	jq -n \
	  --arg port "$port" \
	  --arg prof "$prof" \
	  --arg logLevel "$log_level" \
	  --arg raftHeartbeatPort "$raft_heartbeat_port" \
	  --arg raftReplicaPort "$raft_replica_port" \
	  --arg exporterPort "$exporter_port" \
	  --arg masterAddrs "$CBFS_MASTER_ADDRS" \
	  --arg totalMem "$total_mem" \
	  --arg consulAddr "$consul_addr" \
	    '{
	     "role": "metanode",
	     "listen": $port,
	     "prof": $prof,
	     "logLevel": $logLevel,
	     "metadataDir": "/cfs/data/metaNode/data",
	     "logDir": "/cfs/logs",
	     "raftDir": "/cfs/data/metaNode/raft",
	     "raftHeartbeatPort": $raftHeartbeatPort,
	     "raftReplicaPort": $raftReplicaPort,
	     "consulAddr": $consulAddr,
	     "exporterPort": $exporterPort,
	     "totalMem": $totalMem,
	     "masterAddr": $masterAddrs
	 }' | jq '.masterAddr |= split(",")' > /cfs/conf/metanode.json
}

function create_datanode_config() {
	if [ 0$CBFS_MASTER_ADDRS == 0 ]; then
		print "env CBFS_MASTER_ADDRS not exist"
		exit 1
	fi

	if [ 0$CBFS_DISKS == 0 ]; then
		print "env CBFS_DISKS not exist"
		exit 1
	fi

	local port=${CBFS_PORT:-17310}
	local prof=${CBFS_PROF:-17320}
	local log_level=${CBFS_LOG_LEVEL:-error}
	local raft_heartbeat_port=${CBFS_RAFT_HEARTBEAT_PORT:-17330}
	local raft_replica_port=${CBFS_RAFT_REPLICA_PORT:-17340}
	local exporter_port=${CBFS_EXPORTER_PORT:-17350}
	local consul_addr=${CBFS_CONSUL_ADDR:-http://consul-service.chubaofs.svc.cluster.local:8500}

	jq -n \
	  --arg port "$port" \
	  --arg prof "$prof" \
	  --arg logLevel "$log_level" \
	  --arg raftHeartbeat "$raft_heartbeat_port" \
	  --arg raftReplica "$raft_replica_port" \
	  --arg masterAddr "$CBFS_MASTER_ADDRS" \
	  --arg exporterPort "$exporter_port" \
	  --arg consulAddr "$consul_addr" \
	  --arg disks "$CBFS_DISKS" \
	  --arg zone "$CBFS_ZONE" \
	  '{
	    "role": "datanode",
	    "listen": $port,
	    "prof": $prof,
	    "logDir": "/cfs/logs",
	    "logLevel": $logLevel,
	    "raftHeartbeat": $raftHeartbeat,
	    "raftReplica": $raftReplica,
	    "raftDir": "/cfs/data/dataNode/raft",
	    "consulAddr": $consulAddr,
	    "exporterPort": $exporterPort,
	    "masterAddr": $masterAddr,
	    "zone": $zone,
	    "disks": $disks
	}' | jq '.masterAddr |= split(",")' | jq '.disks |= split(",")' > /cfs/conf/datanode.json
}

function create_objectnode_config() {
	if [ 0$CBFS_DOMAINS == 0 ]; then
		print "env CBFS_DOMAINS not exist"
		exit 1
	fi

	if [ 0$CBFS_MASTER_ADDRS == 0 ]; then
		print "env CBFS_MASTER_ADDRS not exist"
		exit 1
	fi

	local port=${CBFS_PORT:-17510}
	local prof=${CBFS_PROF:-17520}
	local log_level=${CBFS_LOG_LEVEL:-error}
	local exporter_port=${CBFS_EXPORTER_PORT:-17550}
	local consul_addr=${CBFS_CONSUL_ADDR:-http://consul-service.chubaofs.svc.cluster.local:8500}
	
	jq -n \
	  --arg port "$port" \
	  --arg prof "$prof" \
	  --arg logLevel "$log_level" \
	  --arg consulAddr "$consul_addr" \
	  --arg exporterPort "$exporter_port" \
	  --arg masterAddrs "$CBFS_MASTER_ADDRS" \
	  --arg domains "$CBFS_DOMAINS" \
	    '{
	     "role": "objectnode",
	     "listen": $port,
	     "prof": $prof,
	     "logLevel": $logLevel,
	     "logDir": "/cfs/logs",
	     "consulAddr": $consulAddr,
	     "exporterPort": $exporterPort,
	     "domains": $domains,
	     "masterAddr": $masterAddrs
	 }' | jq '.masterAddr |= split(",")' | jq '.domains |= split(",")' > /cfs/conf/objectnode.json
}

function start_master() {
	# before every start, config file must be regenerated
	create_master_config
	start_cfs_server $ROLE_MASTER
}

function start_metanode() {
	# before every start, config file must be regenerated
	create_metanode_config
	start_cfs_server $ROLE_METANODE
}

function start_datanode() {
	# before every start, config file must be regenerated
	create_datanode_config
	start_cfs_server $ROLE_DATANODE
}

function start_objectnode() {
	# before every start, config file must be regenerated
	create_objectnode_config
	start_cfs_server $ROLE_OBJECTNODE
}

function start_client() {
	local master_addr="$1"
	local vol_name="$2"	
	local owner=$3
	if [ "X$master_addr" == "X" ]; then
		print "not found masterAddrs parameter"
		exit 1
	fi

	master_addr=${master_addr%%,*}
	vol_name=${vol_name:-demovol}
	owner=${owner:-demouser}
	print "args:$master_addr, $vol_name, $owner"
	
	# check chubaofs cluster status, then create a vol for testing
	check_and_create_volume ${master_addr} ${vol_name} ${owner}

	# before every start, config file must be regenerated
	mkdir -p /cfs/mnt
	jq -n \
	  --arg masterAddr "$1" \
	  --arg volName "$vol_name" \
	  --arg owner "$owner" \
	  '{
	  "mountPoint": "/cfs/mnt",
	  "volName": $volName,
	  "owner": $owner,
	  "masterAddr": $masterAddr,
	  "logDir": "/cfs/logs",
	  "logLevel": "error",
	  "consulAddr": "",
	  "exporterPort": 17450,
	  "profPort": 17420
	}' > /cfs/conf/client.json

	start_cfs_client $ROLE_CLIENT
}

function check_and_create_volume() {
	local master_addr="$1"
	local vol_name="$2"	
	local owner=$3
	check_master_service ${master_addr}
	check_service ${master_addr} "MetaNode"
	check_service ${master_addr} "DataNode"
	create_volume ${master_addr} ${vol_name} ${owner}
}

# Create a volume in the cluster of ChubaoFS
function create_volume {
	local master_addr="$1"
	local vol_name="$2"	
	local owner=$3
	resp=$(curl -s "http://${master_addr}/admin/createVol?name=${vol_name}&capacity=20&owner=${owner}&mpCount=3" || echo "")
	if [ "X${resp}" == "X" ]; then
		print "create volume fail"
		exit 1
	fi	

	code=$(echo ${resp} | jq ".code")
	if [ "X${code}" != "X0" ]; then
		msg=$(echo ${resp} | jq ".msg")
		if [[ $msg =~ ^.*duplicate\s+vol.*$ ]]; then
			echo "volume[$vol_name] is already exist."
		else
			print "create volume fail, error:${msg}"
			exit 1
		fi
	fi	
}

# Only check DataNode and MetaNode in this function
function check_service() {
	local master_addr="$1"
	local node="$2"	
	up=0
	print "check ${node}"
	for i in $(seq 1 200) ; do
		cluster_info=$(curl -s "http://${master_addr}/admin/getCluster"  || echo "")
		node_total_gb=$( echo ${cluster_info} | jq ".data.${node}StatInfo.TotalGB" )
		if [[ $node_total_gb -gt 0 ]]  ; then
			up=1
			break
		fi
		echo -n "."
		sleep 2
	done

	if [ $up -eq 0 ] ; then
		print "check ${node} service status timeout, exit"
		cluster_info=$(curl -s "http://${master_addr}/admin/getCluster"  || echo "")
		echo $cluster_info | jq .
		exit 2
	fi

	print "${node} service is already"
}

# Check master service
function check_master_service() {
	local master_addr="$1"
	master_addr=${master_addr%%,*}
	if [ "X$master_addr" == "X" ]; then
		print "not found masterAddrs parameter"
		exit 1
	fi

	while true 
	do
		local cluster_info=$(curl -s "http://${master_addr}/admin/getCluster"  || echo "")
		if [ "X${cluster_info}" == "X" ]; then
			print "cluster service not ok"
			sleep 3s
			continue
		fi	
		
		echo ${cluster_info} | jq ".data.LeaderAddr"
		if [ $? -eq 0 ]; then
			break
		fi

		print "cluster service not ok"
		sleep 3s
	done
	print "cluster service is already"
}

if [ $# == 0 ]; then
	help
	exit 1
fi

while [[ $# -ge 1 ]]; do
	type="$1"
	shift
	case "$type" in
		-h | --help ) help ;;
		$ROLE_MASTER ) 
			start_master
			;;
		$ROLE_METANODE ) 
			start_metanode 
			;;
		$ROLE_DATANODE ) 
			start_datanode
			;;
		$ROLE_OBJECTNODE ) 
			start_objectnode
			;;
		$ROLE_CLIENT ) 
			start_client $*
			;;
		check ) 
			check_master_service $* 
			;;
		* ) help ;;
	esac
	shift $#
done

