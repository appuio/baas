#!/bin/sh

date
echo "executing restic backup"

restic init

restic backup \
  --hostname oc1 \
  --one-file-system \
  /data && \
echo "[INFO] listing available snapshots" && \
restic snapshots \
  --no-lock \
  --host oc1 && \
echo curl -fsS --retry 3 https://hchk.io/
