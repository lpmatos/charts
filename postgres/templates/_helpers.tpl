{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "postgres.secret.name" -}}
{{- $name := .Values.postgres.name -}}
{{- printf "%s-%s" $name "secret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Return the proper postgres image name. */}}
{{- define "postgres.image" -}}
{{- $repository := .Values.postgres.image.repository -}}
{{- $tag := .Values.postgres.image.tag | toString -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}

{{/* Define all postgres environment vars in the format key:value. */}}
{{- define "postgres.envs" -}}
{{- range $KEY, $VALUE := .Values.postgres.envs }}
- name: {{ $KEY }}
  value: {{ $VALUE | quote }}
{{- end -}}
{{- end -}}

{{/* Define all postgres commom environment vars in the format key:value. */}}
{{- define "postgres.commom.envs" -}}
- name: POSTGRES_HOST
  value: {{ .Values.postgres.name }}
- name: POSTGRES_USER
  value: {{ .Values.postgres.postgresqlUsername | quote }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgres.secret.name" . }}
      key: postgresql-password
{{- if .Values.postgres.postgresqlDatabase }}
- name: POSTGRES_DB
  value: {{ .Values.postgres.postgresqlDatabase | quote }}
{{- end }}
{{- end -}}

{{/* Return PostgreSQL postgres user password */}}
{{- define "postgresql.postgres.password" -}}
{{- if .Values.postgres.postgresqlPostgresPassword -}}
  {{- .Values.postgres.postgresqlPostgresPassword -}}
{{- else -}}
  {{- randAlphaNum 10 -}}
{{- end -}}
{{- end -}}

{{/* Return PostgreSQL password */}}
{{- define "postgresql.password" -}}
{{- if .Values.postgres.postgresqlPassword -}}
  {{- .Values.postgres.postgresqlPassword -}}
{{- else -}}
  {{- randAlphaNum 10 -}}
{{- end -}}
{{- end -}}

{{/* Get the readiness probe command */}}
{{- define "postgresql.readinessProbeCommand" -}}
- |
{{- if contains "bitnami/" .Values.postgres.image.repository }}
  [ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]
{{- end -}}
{{- end -}}
