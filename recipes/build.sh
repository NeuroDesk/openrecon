#!/bin/bash
set -e

# check and install dependencies
if ! pip3 show jsonschema &> /dev/null; then
    pip3 install jsonschema
fi

if ! pip3 show packaging &> /dev/null; then
    pip3 install packaging
fi

if ! command -v 7z &> /dev/null; then
    sudo apt install -y p7zip
fi

if ! command -v pandoc &> /dev/null; then
    sudo apt install -y pandoc
fi

# check docker version
python ../checkDockerVersion.py

# build pdf file
pandoc --from=gfm --to=pdf -o README.pdf README.md

# build zip file
python build.py
