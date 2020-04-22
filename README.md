
# chubaofs-helm

## Deploy ChubaoFS using Kubernetes and Helm

The chubaofs-helm project helps deploy a ChubaoFS cluster orchestrated by Kubernetes.

### Prerequisite 
- Kubernetes 1.12+
- CSI spec version 0.3.0
- Helm 3

### Download chubaofs-helm

```
$ git clone https://github.com/chubaofs/chubaofs-helm
$ cd chubaofs-helm
```

### Copy kubeconfig file
ChubaoFS CSI driver will use client-go to connect the Kubernetes API Server. First you need to copy the kubeconfig file to `chubaofs-helm/chubaofs/config/` directory, and rename to kubeconfig

```
$ cp ~/.kube/config chubaofs/config/kubeconfig
```

### Create configuration yaml file

Create a `chubaofs.yaml` file, and put it in a user-defined path. Suppose this is where we put it.

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
  total_mem: "26843545600"

provisioner:
  kubelet_path: /var/lib/kubelet
```

> Note that `chubaofs-helm/chubaofs/values.yaml` shows all the config parameters of ChubaoFS.
> The parameters `path.data` and `path.log` are used to store server data and logs, respectively.

### Add labels to Kubernetes node

You should tag each Kubernetes node with the appropriate labels accorindly for server node and CSI node of ChubaoFS.

```
kubectl label node <nodename> chuabaofs-master=enabled
kubectl label node <nodename> chuabaofs-metanode=enabled
kubectl label node <nodename> chuabaofs-datanode=enabled
kubectl label node <nodename> chubaofs-csi-node=enabled
```

### Deploy ChubaoFS cluster
```
$ helm install chubaofs ./chubaofs -f ~/chubaofs.yaml
```

The output of `helm install` shows servers to be deployed.

Use the following command to check pod status, which may take a few minutes.

```
$ kubectl -n chubaofs get pods
NAME                         READY   STATUS    RESTARTS   AGE
cfs-csi-controller-cfc7754b-ptvlq   3/3     Running   0          2m40s
cfs-csi-node-q262p                  2/2     Running   0          2m40s
cfs-csi-node-sgvtf                  2/2     Running   0          2m40s
client-55786c975d-vttcx             1/1     Running   0          2m40s
consul-787fdc9c7d-cvwgz             1/1     Running   0          2m40s
datanode-2rcmz                      1/1     Running   0          2m40s
datanode-7c9gv                      1/1     Running   0          2m40s
datanode-s2w8z                      1/1     Running   0          2m40s
grafana-6964fd5775-6z5lx            1/1     Running   0          2m40s
master-0                            1/1     Running   0          2m40s
master-1                            1/1     Running   0          2m34s
master-2                            1/1     Running   0          2m27s
metanode-bwr8f                      1/1     Running   0          2m40s
metanode-hdn5b                      1/1     Running   0          2m40s
metanode-w9snq                      1/1     Running   0          2m40s
objectnode-6598bd9c87-8kpvv         1/1     Running   0          2m40s
objectnode-6598bd9c87-ckwsh         1/1     Running   0          2m40s
objectnode-6598bd9c87-pj7fc         1/1     Running   0          2m40s
prometheus-6dcf97d7b-5v2xw          1/1     Running   0          2m40s
```

Check cluster status

```
helm status chubaofs
```

## Use ChubaoFS CSI as backend storage

After installing ChubaoFS using helm, the StorageClass named `cfs-sc` of ChubaoFS has been created. Next, you can to create
a PVC that the `storageClassName`  value is `cfs-sc` to using ChubaoFS as backend storage.

An example `pvc.yaml` is shown below.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cfs-pvc
spec:
  accessModes:
  - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 5Gi
  storageClassName: cfs-sc
```

```
$ kubectl create -f pvc.yaml
```

There is an example `deployment.yaml` using the PVC as below

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cfs-csi-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cfs-csi-demo-pod
  template:
    metadata:
      labels:
        app: cfs-csi-demo-pod
    spec:
      nodeSelector:
        chubaofs-csi-node: enabled
      containers:
        - name: cfs-csi-demo
          image: nginx:1.17.9
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 80
              name: "http-server"
          volumeMounts:
            - mountPath: "/usr/share/nginx/html"
              name: mypvc
      volumes:
        - name: mypvc
          persistentVolumeClaim:
            claimName: cfs-pvc
```

```
$ kubectl create -f deployment.yaml
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

## Uninstall ChubaoFS 

uninstall ChubaoFS cluster using helm

```
helm delete chubaofs
```
