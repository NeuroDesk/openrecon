#!/bin/bash
set -e
#This script will run inside the tool directory

# check and install dependencies
if ! command -v pip3 &> /dev/null; then
    sudo apt update
    sudo apt install -y python3-pip
fi

if ! pip3 show jsonschema &> /dev/null; then
    pip3 install jsonschema
fi

if ! pip3 show packaging &> /dev/null; then
    pip3 install packaging
fi

if ! command -v 7z &> /dev/null; then
    sudo apt install -y p7zip
    sudo apt install -y p7zip-full
fi

if ! command -v mdpdf &> /dev/null; then
    # check if directory $HOME/.nvm exists:
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        source ~/.bashrc
        nvm list-remote
        nvm install v22.3.0
        nvm list
        npm install mdpdf -g
    else
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    fi
fi

# check docker version
python3 ../checkDockerVersion.py

# build pdf file from README.md
mdpdf README.md

# source tool-specific parameters
source params.sh

# replace VERSION_WILL_BE_REPLACED_BY_SCRIPT in OpenReconLabel.json with $version
sed -i "s/VERSION_WILL_BE_REPLACED_BY_SCRIPT/$version/g" OpenReconLabel.json

echo "This is the OpenReconLabel.json file:"
echo "----------------------------------------"
cat OpenReconLabel.json
echo "----------------------------------------"

echo "baseDockerImage: $baseDockerImage"

# build zip file
echo "Building OpenRecon file..."
python3 ../build.py
