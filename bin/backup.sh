#!/bin/sh

if [ -z ${NAMESPACE} ]; then
  echo "[FATAL] NAMESPACE is not defined"
  exit 1
fi

echo "[INFO] - [${NAMESPACE}] - storing volumes ${VOLUMES}"

restic backup \
  --hostname ${NAMESPACE} \
  --tag volumes
  /data && \

echo "[INFO] - [${NAMESPACE}] - listing available snapshots" && \
restic snapshots \
  --no-lock \
  --host ${NAMESPACE} && \

echo "[INFO] - [${NAMESPACE}] - notifying monitoring" && \
echo curl -fsS --retry 3 https://hchk.io/


echo "[INFO] - [${NAMESPACE}] - storing databases"

# Find databases with oc label filter
# Connect to them using oc rsh and stdout / stdin redirection
## restic backup \
##   --hostname ${NAMESPACE} \
##   --tag postgres
##   --stdin \
##   --stdin-filename postgres
