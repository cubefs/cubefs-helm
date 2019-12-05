
# ChubaoFS Helm Chart

## Introduction

ChubaoFS is a distributed file system for cloud native applications. This chart deploy ChubaoFS on a Kubernetes cluster using Helm. It supports Helm v2 and Hell v3.

## Pre Requestes

- Kubernetes 1.16+

## Add ChubaoFS Helm Chart repository

```
$ helm repo add chubaofs https://chubaofs.github.io/chubaofs-charts
$ helm repo update
```

### Configure and install chart 

The configuration detail refer to [README.md](https://github.com/chubaofs/chubaofs-helm) .
After successful configuration, you can use this command to install the Chart into your kubernetes cluster

```
$ helm install --name=chubaofs chubaofs/chubaofs -f ~/chubaofs.yaml
```


