#!/bin/sh

# TODO: Generate objects in Icinga2

restic_volumes() {
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
}

restic_postgres() {
  echo "[INFO] - [${NAMESPACE}] - storing databases"

# Find databases with oc label filter
# Connect to them using oc rsh and stdout / stdin redirection
#oc -n ${NAMESPACE}
## restic backup \
##   --hostname ${NAMESPACE} \
##   --tag postgres \
##   --tag ${POD_NAME} \
##   --stdin \
##   --stdin-filename postgres
}

if [ -z ${NAMESPACE} ]; then
  echo "[FATAL] NAMESPACE is not defined"
  exit 1
fi

if [ -z ${POD_NAME} ]; then
  echo "[FATAL] POD_NAME is not defined"
  exit 1
fi

case $1 in
  volumes)
    restic_volumes
    ;;
  postgres)
    restic_postgres
    ;;
  *)
    echo "unknown action"
    exit 1
esac
