{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "chubaofs-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "chubaofs-helm.namespace" -}}
{{- .Release.Namespace | default .Values.namespace -}}
{{- end -}}

{{- define "chubaofs.master.peers" -}}
{{- range $i, $e := until (.Values.master.replicas | int) -}}
{{ if ne $i 0 }},{{ end }}{{ $i | add1 }}:master-{{ $i }}.master-service.{{- $.Values.namespace -}}.svc.cluster.local:{{- $.Values.master.port -}}
{{- end -}}
{{- end -}}

{{- define "chubaofs.master.master-service" -}}
master-service.{{- $.Values.namespace -}}.svc.cluster.local
{{- end -}}

{{- define "chubaofs.master.master-service.address" -}}
master-service.{{- $.Values.namespace -}}.svc.cluster.local:{{- $.Values.master.port }}
{{- end -}}

{{- define "chubaofs.monitor.consul.address" -}}
{{- $envAll := index . 0 -}}
consul-service.{{- $envAll.Values.namespace -}}.svc.cluster.local:{{- $envAll.Values.consul.port }}
{{- end -}}

{{- define "chubaofs.monitor.consul.url" -}}
{{- $envAll := index . 0 -}}
http://consul-service.{{- $envAll.Values.namespace -}}.svc.cluster.local:{{- $envAll.Values.consul.port }}
{{- end -}}

{{- define "chubaofs.monitor.prometheus.url" -}}
{{- $envAll := index . 0 -}}
http://prometheus-service.{{- $envAll.Values.namespace -}}.svc.cluster.local:{{- $envAll.Values.prometheus.port }}
{{- end -}}

{{- define "chubaofs.datanode.disks" -}}
{{- range $i, $e := .Values.datanode.disks -}}
{{ if ne $i 0 }},{{ end }}{{- $e.device -}}:{{- $e.retain_space -}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.metadata_labels" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}
application: {{ $application }}
component: {{ $component }}
app_version: {{ $envAll.Chart.Version }}
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