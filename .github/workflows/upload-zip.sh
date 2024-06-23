#!/bin/bash
set -e

ZIPFILE=$1
IMAGENAME=$(echo $(basename $ZIPFILE .zip))

echo "[DEBUG] ZIPFILE: $ZIPFILE"
echo "[DEBUG] IMAGENAME: $IMAGENAME"

ls -la $ZIPFILE

#This prevents the sometimes stuck apt process from stopping the build
if [ -f "/var/lib/apt/lists/lock" ]; then
  sudo rm /var/lib/apt/lists/lock
  sudo rm /var/cache/apt/archives/lock
  sudo rm /var/lib/dpkg/lock*
fi

echo "[DEBUG] checking rclone config ..."
cat ~/.config/rclone/rclone.conf

echo "[DEBUG] Attempting upload to AWS Object Storage ..."
rclone copy --progress $ZIPFILE aws-neurocontainers:/openrecon

if curl --output /dev/null --silent --head --fail "https://openrecon.neurodeks.org/${IMAGENAME}.zip"; then
    echo "[DEBUG] ${IMAGENAME}.zip was freshly build and exists now :)"
    echo "[DEBUG] cleaning up $ZIPFILE and ${ZIPFILE%.zip}.tar "
    rm $ZIPFILE
    rm ${ZIPFILE%.zip}.tar
else
    echo "[ERROR] ${IMAGENAME}.zip does not exist yet. Something is WRONG"
    exit 2
fi

