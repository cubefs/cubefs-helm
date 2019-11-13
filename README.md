
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

The output of `helm install` shows servers to be deployed.

Use the following command to check pod status, which may take a few minutes.

```
$ kubectl -n chubaofs get pods
NAME                         READY   STATUS    RESTARTS   AGE
client-6cb87f4f-xrhfm        1/1     Running   0          21s
consul-59ddb8cffc-p7hw9      1/1     Running   0          68s
datanode-89fxb               1/1     Running   0          67s
datanode-jgjqc               1/1     Running   0          67s
datanode-lfsqv               1/1     Running   0          67s
datanode-qm8hz               1/1     Running   0          67s
grafana-65ccb7f885-n4ggz     1/1     Running   0          68s
master-0                     1/1     Running   0          67s
master-1                     1/1     Running   0          59s
master-2                     1/1     Running   0          53s
metanode-5qg7r               1/1     Running   0          67s
metanode-8xc2r               1/1     Running   0          68s
metanode-xjstj               1/1     Running   0          67s
prometheus-588f669b6-26dbp   1/1     Running   0          68s
```

Check cluster status

```
helm status chubaofs
```

Delete cluster

```
helm delete --purge chubaofs
```

## Config Monitoring System (optional)

Monitor daemons are started if the cluster is deployed with chubaofs-helm. ChubaoFS uses Consul, Prometheus and Grafana to construct the monitoring system.

Accessing the monitor dashboard requires Kubernetes Ingress Controller. In this example, the [Nginx Ingress](https://github.com/kubernetes/ingress-nginx) is used. Download the [default config yaml file](https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml), and add `hostNetwork: true` in the `spec` section.

```yaml
spec:
  # wait up to five minutes for the drain of connections
  terminationGracePeriodSeconds: 300
  serviceAccountName: nginx-ingress-serviceaccount
  hostNetwork: true
  nodeSelector:
    kubernetes.io/os: linux
```

Start the ingress controller

```
$ kubectl apply -f mandatory.yaml
```

Get the IP address of Nginx ingress controller.

```
$ kubectl get pods -A -o wide | grep nginx-ingress-controller
ingress-nginx   nginx-ingress-controller-5bbd46cd86-q88sw    1/1     Running   0          115m   10.196.31.101   host-10-196-31-101   <none>           <none>
```

Get the host name of Grafana which should also be used as domain name.

```
$ kubectl get ingress -n chubaofs
NAME      HOSTS                  ADDRESS         PORTS   AGE
grafana   monitor.chubaofs.com   10.106.207.55   80      24h
```

Add a local DNS in `/etc/hosts` in order for a request to find the ingress controller.

```
10.196.31.101 monitor.chubaofs.com
```

At this point, dashboard can be visited by `http://monitor.chubaofs.com`.
