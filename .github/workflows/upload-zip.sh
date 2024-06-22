#!/bin/bash
set -e

echo "[DEBUG] recipes/$APPLICATION"
cd recipes/$APPLICATION

IMAGENAME=$1
IMAGE_HOME=/storage/openrecon

echo "[DEBUG] IMAGENAME: $IMAGENAME"

ls -la $IMAGE_HOME/$IMAGENAME.zip


#This prevents the sometimes stuck apt process from stopping the build
if [ -f "/var/lib/apt/lists/lock" ]; then
  sudo rm /var/lib/apt/lists/lock
  sudo rm /var/cache/apt/archives/lock
  sudo rm /var/lib/dpkg/lock*
fi

echo "[DEBUG] Attempting upload to AWS Object Storage ..."
rclone copy --progress $IMAGE_HOME/${IMAGENAME}.zip aws-neurocontainers:/openrecon

if curl --output /dev/null --silent --head --fail "https://openrecon.neurodeks.org/${IMAGENAME}.zip"; then
    echo "[DEBUG] ${IMAGENAME}.simg was freshly build and exists now :)"
    echo "[DEBUG] cleaning up $IMAGE_HOME/${IMAGENAME}.zip"
    rm -rf $IMAGE_HOME/${IMAGENAME}.zip
else
    echo "[ERROR] ${IMAGENAME}.zip does not exist yet. Something is WRONG"
    echo "[ERROR] cleaning up $IMAGE_HOME/${IMAGENAME}.zip"
    rm -rf $IMAGE_HOME/${IMAGENAME}.zip
    exit 2
fi

