{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "svc-b.name" -}}
{{- default "svc-b" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "svc-b.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "svc-b" .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "svc-b.chart" -}}
{{- printf "%s-%s" "svc-b" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "svc-b.labels" -}}
helm.sh/chart: {{ include "svc-b.chart" . }}
{{ include "svc-b.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "svc-b.selectorLabels" -}}
app.kubernetes.io/name: {{ include "svc-b.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: service
app.kubernetes.io/owner: retail-store-sample
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "svc-b.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "svc-b.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the config map to use
*/}}
{{- define "svc-b.configMapName" -}}
{{- if .Values.configMap.create }}
{{- default (include "svc-b.fullname" .) .Values.configMap.name }}
{{- else }}
{{- default "default" .Values.configMap.name }}
{{- end }}
{{- end }}

{{/* podAnnotations */}}
{{- define "svc-b.podAnnotations" -}}
{{- if or .Values.metrics.enabled .Values.podAnnotations }}
{{- $podAnnotations := .Values.podAnnotations}}
{{- $metricsAnnotations := .Values.metrics.podAnnotations}}
{{- $allAnnotations := merge $podAnnotations $metricsAnnotations}}
{{- toYaml $allAnnotations }}
{{- end }}
{{- end -}}

{{- define "svc-b.dynamodb.fullname" -}}
{{- include "svc-b.fullname" . }}-dynamodb
{{- end -}}

{{/*
Common labels for dynamodb
*/}}
{{- define "svc-b.dynamodb.labels" -}}
helm.sh/chart: {{ include "svc-b.chart" . }}
{{ include "svc-b.dynamodb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for dynamodb
*/}}
{{- define "svc-b.dynamodb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "svc-b.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: dynamodb
app.kubernetes.io/owner: retail-store-sample
{{- end }}