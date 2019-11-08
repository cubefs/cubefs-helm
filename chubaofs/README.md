# chubaofs-helm

The chubaofs-helm chart adds chubaofs to your cluster.

## Install Chart

To install the Chart into your Kubernetes cluster

```bash
helm install --namespace "chubaofs" --name "chubaofs" ceph-csi/ceph-csi-cephfs
```

After installation succeeds, you can get a status of Chart

```bash
helm status "chubaofs"
```

If you want to delete your Chart, use this command

```bash
helm delete --purge "chubaofs"
```
