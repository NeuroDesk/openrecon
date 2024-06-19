#!/bin/bash
set -e

pip3 install jsonschema
pip3 install packaging

sudo apt install p7zip

sudo apt remove docker
wget https://desktop.docker.com/linux/main/amd64/131620/docker-desktop-4.26.1-x86_64.rpm
sudo dpkg -i docker-desktop-4.26.1-x86_64.rpm

python ../checkDockerVersion.py

# build zip file
python build.py

