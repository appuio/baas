#!/bin/sh

if [ -z ${NAMESPACE} ]; then
  echo "NAMESPACE is not defined"
  exit 1
fi

echo "executing restic backup in namespace ${NAMESPACE}"

restic backup \
  --hostname ${NAMESPACE} \
  --one-file-system \
  /data && \
echo "[INFO] listing available snapshots" && \
restic snapshots \
  --no-lock \
  --host ${NAMESPACE} && \
echo curl -fsS --retry 3 https://hchk.io/
