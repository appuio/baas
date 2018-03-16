#!/bin/sh

if [ -z ${NAMESPACE} ]; then
  echo "[FATAL] NAMESPACE is not defined"
  exit 1
fi

if [ -z ${POD_NAME} ]; then
  echo "[FATAL] POD_NAME is not defined"
  exit 1
fi

echo "[INFO] - [${NAMESPACE}] - storing volumes"

restic backup \
  --hostname ${NAMESPACE} \
  --tag volumes \
  --tag ${POD_NAME} \
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
##   --tag postgres \
##   --tag ${POD_NAME} \
##   --stdin \
##   --stdin-filename postgres
