
# chubaofs-helm

## Deploy ChubaoFS using Kubernetes and Helm

The chubaofs-helm project helps deploy a ChubaoFS cluster orchestrated by Kubernetes.

### Init Helm

``` 
$ helm init
```

### Start Helm

```
$ helm serve &
$ helm repo add local http://localhost:8879/charts
```

### Add chubaofs-helm to the local repository

```
$ git clone https://github.com/chubaofs/chubaofs-helm
$ cd chubaofs-helm
$ make
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
    - device: /dev/sda
      retain_space: "21474836480"
    - device: /dev/sdb
      retain_space: "21474836480"
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
$ helm install --name=chubaofs local/chubaofs -f ~/chubaofs.yaml
```

The output of `helm install` shows servers to be deployed, and use the following command to check pod status, which may take a few minutes.

```
$ kubectl -n chubaofs get pods
```

Check cluster status

```
helm status chubaofs
```

Delete cluster

```
helm delete --purge chubaofs
```