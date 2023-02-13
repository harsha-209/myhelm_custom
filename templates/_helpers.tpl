{{/*
Selector labels
*/}}
{{- define "harshad.Labels" -}}
city: {{ .Values.labels.city | quote }}
name: {{ .Release.Name }}
{{- end -}}


{{- /*
lables with range function to call multiple keys and values
*/}}
{{- define "myharshad.labels" }}
{{- range $key, $val := .Values.labels }}
{{ $key }}: {{ $val | quote }}
{{- end -}}
{{- end -}}

{{/*
calling configmaps with range function by defined as required below
\*}}
{{- define "myharshad.configmap" -}}
  {{- range $key, $val := .Values.configmaps}}
  {{ $key }} : {{ $val | quote }}
  {{- end -}}
{{- end -}}




{{/*
Expand the name of the chart.
As per my understanding from below function
by default it pick name value from .Chart.Name or if values.nameOverride values is specified in values.yaml file
*/}}
{{- define "myhelmchart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}



{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
As per my understanding 
fullname value will taken from by following below conditions
if user provide any value from fullnameoverride in values.yaml then it will call values from it
or 
it will follow another condtion to call .Chart.name value by default only if .values.nameoverride value is not mentioned
to stasfy above function it depended on another function where contains function, when Chart.name will matches with .Release.Name like(catch = cat)
or 
it print the value like .Release.Name-$name ( if Release.Name is harhad and suppose chart.name or nameoverride value like sai )then 
return value is 
harshad-sai
*/}}
{{- define "myhelmchart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "myhelmchart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}




{{/*
Common labels
*/}}
{{- define "myhelmchart.labels" -}}
helm.sh/chart: {{ include "myhelmchart.chart" . }}
{{ include "myhelmchart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}



{{/*
Selector labels
*/}}
{{- define "myhelmchart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "myhelmchart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}




{{/*
Create the name of the service account to use
*/}}
{{- define "myhelmchart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "myhelmchart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

