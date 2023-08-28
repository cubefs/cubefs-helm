{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cubefs-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cubefs-helm.namespace" -}}
{{- .Release.Namespace | default .Values.namespace -}}
{{- end -}}

{{- define "cubefs.master.peers" -}}
{{- range $i, $e := until (.Values.master.replicas | int) -}}
{{ if ne $i 0 }},{{ end }}{{ $i | add1 }}:master-{{ $i }}.master-service:{{- $.Values.master.port -}}
{{- end -}}
{{- end -}}

{{- define "cubefs.master-service.with.port" -}}
master-service:{{- $.Values.master.port -}}
{{- end -}}

{{- define "cubefs.master-service" -}}
master-service
{{- end -}}

{{- define "cubefs.master.address.array" -}}
{{- range $i, $e := until (.Values.master.replicas | int) -}}
{{ if ne $i 0 }},{{ end }}master-{{ $i }}.master-service:{{- $.Values.master.port -}}
{{- end -}}
{{- end -}}

{{- define "cubefs.monitor.consul.address" -}}
{{- $envAll := index . 0 -}}
http://consul-service:{{- $envAll.Values.consul.port }}
{{- end -}}

{{- define "cubefs.monitor.consul.url" -}}
{{- $envAll := index . 0 -}}
{{- if $envAll.Values.consul.external_address -}}
{{$envAll.Values.consul.external_address}}
{{- else -}}
http://consul-service:{{$envAll.Values.consul.port }}
{{- end -}}
{{- end -}}

{{- define "cubefs.monitor.prometheus.url" -}}
{{- $envAll := index . 0 -}}
http://prometheus-service:{{- $envAll.Values.prometheus.port }}
{{- end -}}

{{- define "cubefs.datanode.disks" -}}
{{- range $i, $e := .Values.datanode.disks -}}
{{ if ne $i 0 }},{{ end }}{{- $e -}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.metadata_labels" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}
app.kubernetes.io/name: {{ $application }}
app.kubernetes.io/component: {{ $component }}
app.kubernetes.io/version: {{ $envAll.Chart.Version }}
{{- end -}}

{{- define "helm-toolkit.utils.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{- define "helm-toolkit.utils.container_port" -}}
{{- $envAll := index . 0 -}}
{{- $name := index . 1 -}}
{{- $containerPort := index . 2 -}}
- name: {{ $name }}
  containerPort: {{ $containerPort }}
  protocol: TCP
{{- end -}}

{{- define "helm-toolkit.snippets.kubernetes_resources" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- if $component.enabled -}}
resources:
  limits:
    cpu: {{ $component.limits.cpu | quote }}
    memory: {{ $component.limits.memory | quote }}
  requests:
    cpu: {{ $component.requests.cpu | quote }}
    memory: {{ $component.requests.memory | quote }}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.utils.datanode.disks.volumes" -}}
{{- $envAll := index . 0 -}}
{{- $disk := index . 1 -}}
{{- $diskAndQuotaArray := split ":" $disk -}}
{{- if hasPrefix "/" $diskAndQuotaArray._0  -}}
- name: {{ $diskAndQuotaArray._0 | replace "/" "" }}
  hostPath:
    path: {{ $diskAndQuotaArray._0 }}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.utils.datanode.disks.volumes_mount" -}}
{{- $envAll := index . 0 -}}
{{- $disk := index . 1 -}}
{{- $diskAndQuotaArray := split ":" $disk -}}
{{- if hasPrefix "/" $diskAndQuotaArray._0  -}}
- name: {{ $diskAndQuotaArray._0 | replace "/" "" }}
  mountPath: {{ $diskAndQuotaArray._0 }}
  readOnly: false
{{- end }}
{{- end }}

{{/* Support override kubernetes version */}}
{{- define "cubefs.kubernetes.version" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubernetes.version -}}
{{- end -}}

{{- define "helm-toolkit.utils.blobstore_blobnode.disks.envs" -}}
{{- $envAll := index . 0 -}}
{{- $disk := index . 1 -}}
{{- $diskAndQuotaArray := split ":" $disk -}}
{{- if hasPrefix "/" $diskAndQuotaArray._0  -}}
- name: DISK_DEVICE_{{ $diskAndQuotaArray._0 | replace "/" "" | replace "-" "" }}
  value: {{ $diskAndQuotaArray._1 }}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.utils.blobstore_blobnode.disks.volumes" -}}
{{- $envAll := index . 0 -}}
{{- $disk := index . 1 -}}
{{- $diskAndQuotaArray := split ":" $disk -}}
{{- if hasPrefix "/" $diskAndQuotaArray._0  -}}
- name: {{ $diskAndQuotaArray._0 | replace "/" "" }}
  hostPath:
    path: {{ $diskAndQuotaArray._0 }}
    type: DirectoryOrCreate
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.utils.blobstore_blobnode.disks.volumes_mount" -}}
{{- $envAll := index . 0 -}}
{{- $disk := index . 1 -}}
{{- $diskAndQuotaArray := split ":" $disk -}}
{{- if hasPrefix "/" $diskAndQuotaArray._0  -}}
- name: {{ $diskAndQuotaArray._0 | replace "/" "" }}
  mountPath: {{ $diskAndQuotaArray._1 }}
{{- end }}
{{- end }}