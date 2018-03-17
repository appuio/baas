apiVersion: batch/v1
kind: Job 
metadata:
  name: baas-{{ .Date | formatAsDate }}
spec:
  parallelism: 1
  completions: 1
  template:
    metadata:
      name: baas
    spec:
      restartPolicy: OnFailure
      containers:
        - name: baas
          image: 172.30.1.1:5000/myproject/baas:latest
          command:
            - backup.sh
          env:
          - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              secretKeyRef:
                name: baas
                key: AWS_SECRET_ACCESS_KEY
          - name: AWS_ACCESS_KEY_ID
            valueFrom:
              secretKeyRef:
                name: baas
                key: AWS_ACCESS_KEY_ID
          - name: RESTIC_PASSWORD
            valueFrom:
              secretKeyRef:
                name: baas
                key: RESTIC_PASSWORD
          - name: NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: RESTIC_REPOSITORY
            value: s3:https://objects.cloudscale.ch/restic1/baas
          - name: RESTIC_TAG
            value: latest
          - name: XDG_CACHE_HOME
            value: /tmp
{{- if .Volumes }}
          volumeMounts:
{{ with .Volumes }}{{ range . }}          - mountPath: /data/{{ . }}
            name: {{ . }}
            readOnly: true
{{ end -}}{{ end -}}{{ end -}}
{{- if .Volumes }}      volumes:
{{ with .Volumes }}{{ range . }}      - name: {{ . }}
        persistentVolumeClaim:
        claimName: {{ . }}
{{ end }}{{ end }}{{ end }}