#!/bin/bash
set -e

echo "[DEBUG] recipes/$APPLICATION"
cd recipes/$APPLICATION

IMAGENAME=$1

#This prevents the sometimes stuck apt process from stopping the build
if [ -f "/var/lib/apt/lists/lock" ]; then
  sudo rm /var/lib/apt/lists/lock
  sudo rm /var/cache/apt/archives/lock
  sudo rm /var/lib/dpkg/lock*
fi

echo "[DEBUG] Attempting upload to Nectar Object Storage ..."
rclone copy --progress $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.zip nectar:/neurodesk/openrecon

echo "[DEBUG] Attempting upload to AWS Object Storage ..."
rclone copy --progress $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.zip aws-neurocontainers:/neurocontainers/openrecon

if curl --output /dev/null --silent --head --fail "https://object-store.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/neurodesk/openrecon/${IMAGENAME}_${BUILDDATE}.zip"; then
    echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg was freshly build and exists now :)"
    echo "[DEBUG] cleaning up $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.zip"
    rm -rf $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.zip
else
    echo "[ERROR] ${IMAGENAME}_${BUILDDATE}.zip does not exist yet. Something is WRONG"
    echo "[ERROR] cleaning up $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.zip"
    rm -rf $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.zip
    exit 2
fi

