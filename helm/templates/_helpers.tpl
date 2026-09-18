{{/*
Return the name of the chart.
*/}}
{{- define "roast-co.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Return the fully qualified application name.
*/}}
{{- define "roast-co.fullname" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}


{{/*
Return the chart name and version.
*/}}
{{- define "roast-co.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Common Kubernetes labels.
*/}}
{{- define "roast-co.labels" -}}
helm.sh/chart: {{ include "roast-co.chart" . }}
{{ include "roast-co.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}


{{/*
Labels used by Deployment selectors, Pods and Service selectors.
*/}}
{{- define "roast-co.selectorLabels" -}}
app.kubernetes.io/name: {{ include "roast-co.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}