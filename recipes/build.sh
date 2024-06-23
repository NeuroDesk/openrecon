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

if ! command -v mdpdf &> /dev/null; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    
    if ! command -v mdpdf &> /dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        source ~/.bashrc
        nvm list-remote
        nvm install v22.3.0
        nvm list
        npm install mdpdf -g
    fi
fi

# check docker version
python ../checkDockerVersion.py

# build pdf file from README.md
mdpdf README.md

# build zip file
python build.py
