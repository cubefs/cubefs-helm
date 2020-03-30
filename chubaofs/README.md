
# ChubaoFS Helm Chart

## Introduction

ChubaoFS is a distributed file system for cloud native applications. This chart deploy ChubaoFS on a Kubernetes cluster using Helm. It supports Helm v2 and Helm v3.

## Prerequisite 

- Kubernetes 1.12+
- Helm 3 (If you use Helm v2, please read [this documentation](https://github.com/chubaofs/chubaofs-helm/blob/master/README.md))

## Add ChubaoFS Helm Chart repository

```
$ helm repo add chubaofs https://chubaofs.github.io/chubaofs-charts
$ helm repo update
```

### Create configuration yaml file

Create chubaofs.yaml, an put it in a user-defined path. Suppose this is where we put it.

```
$ cat ~/chubaofs.yaml
```

``` yaml
path:
  data: /chubaofs/data
  log: /chubaofs/log

datanode:
  disks:
    - /data0:21474836480
    - /data1:21474836480
      
metanode:
  total_mem: "2147483648"
```

> Note that `chubaofs-helm/chubaofs/values.yaml` shows all the config parameters of ChubaoFS.
> The parameters `path.data` and `path.log` are used to store server data and logs, respectively.

### Add labels to Kubernetes node

There are 3 roles for ChubaoFS servers, master/metanode/datanode. Tag each Kubernetes node with the appropriate labels accorindly.

```
kubectl label node <nodename> chuabaofs-master=enabled
kubectl label node <nodename> chuabaofs-metanode=enabled
kubectl label node <nodename> chuabaofs-datanode=enabled
```

### Deploy ChubaoFS cluster
```
$ helm install chubaofs chubaofs/chubaofs --version 1.5.0 -f ~/chubaofs.yaml
```

### Delete ChubaoFS cluster
```
$ helm delete chubaofs
```

## Config Monitoring System (optional)
The configuration detail refer to [README.md](https://github.com/chubaofs/chubaofs-helm) 

