#!/bin/sh

get_jobtemplate() {
  echo "
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
              args: ${1}
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
          restartPolicy: OnFailure
  "
}

### Volume backup job

echo "[INFO] - [${NAMESPACE}] - generating backup job for volumes"

# Get list of PVCs in configured namespace
# TODO: filter on annotation
PVCS=$(oc -n ${NAMESPACE} get pvc -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

# If not PVCs, no backup will be made
# TODO: This does skip non-PVC volumes like emptyDir
# Should we add support for them?
if [ -z "$PVCS" ]; then
  echo "[INFO] No PVCs found - will not generate volume backup job"
else
  # Collect all PVCs and prepare for adding as mount
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

  # Create the backup job
  # TODO: How to cleanup old Jobs?
  echo "$(get_jobtemplate ['volumes'])" | oc -n ${NAMESPACE} apply -f -
fi

### application backup job
PODS=$(oc -n ${NAMESPACE} get pods -l backup=true -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
if [ -z "$PODS" ]; then
  echo "[INFO] No matching Pods found - will not generate app backup job"
else
  echo "[INFO] Found app specific backups $PODS"
  echo "$(get_jobtemplate ['apps', '$PODS'])" | oc -n ${NAMESPACE} apply -f -
fi