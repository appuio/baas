#!/bin/sh

PVCS=$(oc -n ${NAMESPACE} get pvc -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

# oc -n ${NAMESPACE} apply -f - <<EOF
for pvc in $PVCS; do
  echo "pvc $pvc"
done
# EOF

#apiVersion: batch/v1
#kind: Job
#metadata:
#  name: baas
#spec:
#  parallelism: 1
#  completions: 1
#  template:
#    metadata:
#      name: baas
#    spec:
#      containers:
#        - name: baas
#          image: 172.30.1.1:5000/myproject/baas:latest
#          command:
#            - backup.sh
#          env:
#          - name: AWS_SECRET_ACCESS_KEY
#            valueFrom:
#              secretKeyRef:
#                name: baas
#                key: AWS_SECRET_ACCESS_KEY
#          - name: AWS_ACCESS_KEY_ID
#            valueFrom:
#              secretKeyRef:
#                name: baas
#                key: AWS_ACCESS_KEY_ID
#          - name: RESTIC_PASSWORD
#            valueFrom:
#              secretKeyRef:
#                name: baas
#                key: RESTIC_PASSWORD
#          - name: NAMESPACE
#            valueFrom:
#              fieldRef:
#                fieldPath: metadata.namespace
#          - name: RESTIC_REPOSITORY
#            value: s3:https://objects.cloudscale.ch/restic1/baas
#          - name: RESTIC_TAG
#            value: latest
#          - name: XDG_CACHE_HOME
#            value: /tmp
#          volumeMounts:
#            - mountPath: /data/pg
#              name: pg
#              readOnly: true
#      volumes:
#        - name: pg
#          persistentVolumeClaim:
#            claimName: postgresql
#      restartPolicy: OnFailure
