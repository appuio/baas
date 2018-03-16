#!/bin/sh

PVCS=$(oc -n ${NAMESPACE} get pvc -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

if [ -z "$PVCS" ]; then
 echo "[FATAL] No PVCs found"
 exit 1
fi

volumeMounts="volumeMounts:"
volumes="volumes:"
for pvc in $PVCS; do
  volumeMounts+="
            - mountPath: /data/${pvc}
              name: ${pvc}
              readOnly: true"
  volumes+="
         - name: ${pvc}
           persistentVolumeClaim:
             claimName: ${pvc}"
done

oc -n ${NAMESPACE} apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: baas-$(date +"%Y%m%d%H%m%S")
spec:
  parallelism: 1
  completions: 1
  template:
    metadata:
      name: baas
    spec:
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
          ${volumeMounts}
      ${volumes}
      restartPolicy: "OnFailure"
EOF
echo $JOB