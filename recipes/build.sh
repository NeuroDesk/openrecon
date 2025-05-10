#!/bin/bash
set -e
#This script will run inside the tool directory

# check and install dependencies
if ! command -v pip3 &> /dev/null; then
    #check if on MacOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install python3
    fi
    # check if on Linux
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # check if apt is available
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y python3 python3-pip
        # check if yum is available
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3 python3-pip
        # check if dnf is available
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip
        else
            echo "Error: No package manager found. Please install Python 3 and pip manually."
            exit 1
        fi
    fi
fi

if ! pip3 show jsonschema &> /dev/null; then
    pip3 install jsonschema
fi

if ! pip3 show packaging &> /dev/null; then
    pip3 install packaging
fi

if ! command -v 7z &> /dev/null; then
    # check if on MacOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install p7zip
    fi
    # check if on Linux
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # check if apt is available
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y p7zip-full
        # check if yum is available
        elif command -v yum &> /dev/null; then
            sudo yum install -y p7zip-full
        # check if dnf is available
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y p7zip-full
        else
            echo "Error: No package manager found. Please install p7zip manually."
            exit 1
        fi
    fi
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
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker."
    exit 1
fi

# check for cli flag if it should ignore the docker version:
if [[ "$1" == "--ignore-docker-version" ]]; then
    echo "Ignoring docker version check."
else
    python3 ../checkDockerVersion.py
fi

# build pdf file from README.md
if [[ "$2" == "--ignore-mdpdf" ]]; then
    echo "Ignoring mdpdf."
else
    mdpdf README.md
fi

# source tool-specific parameters
source params.sh

# replace VERSION_WILL_BE_REPLACED_BY_SCRIPT in OpenReconLabel.json with $version
# run correct sed command on MacOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/VERSION_WILL_BE_REPLACED_BY_SCRIPT/$version/g" OpenReconLabel.json
fi
# run correct sed command on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sed -i "s/VERSION_WILL_BE_REPLACED_BY_SCRIPT/$version/g" OpenReconLabel.json
fi

echo "This is the OpenReconLabel.json file:"
echo "----------------------------------------"
cat OpenReconLabel.json
echo "----------------------------------------"

echo "baseDockerImage: $baseDockerImage"

# build zip file
echo "Building OpenRecon file..."
python3 ../build.py
