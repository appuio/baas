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

detect_app() {
  echo "[INFO] pods to check $1 - connecting to them"
  oc -n ${NAMESPACE} rsh $1 -- ls /var/lib
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
  apps)
    for pod in $2;
      do detect_app $pod
    done
    ;;
  *)
    echo "unknown action ${1}"
    exit 1
esac
