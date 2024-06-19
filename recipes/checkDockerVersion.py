# Copyright Siemens Healthineers AG - All Rights Reserved
# Restricted - Unauthorized copying of this file, via any medium is strictly prohibited
# Version Mar 11th 2024

import subprocess
from packaging import version

def executeCommandDirectly(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    outputString, _ = process.communicate()
    exitCode = process.wait()
    return exitCode, outputString

def checkDockerVersion(dockerVersionMax):    
    print("### Check docker version...")
    exitCode, outputString = executeCommandDirectly(["docker", "--version"])
    if (exitCode != 0):
        raise Exception(f"#-> Docker command failed: " + outputString)
    parsedDockerVersion = outputString.split()[2].rstrip(',')
    if version.parse(parsedDockerVersion) >= version.parse(dockerVersionMax):
        raise Exception(f"""Available docker version {parsedDockerVersion} is greater than maximum supported one {dockerVersionMax}. This is currently not supported by Open Recon.
Please use Docker Engine version <25 (bundled with Docker Desktop 4.26.1 and earlier).
You can get the installer for 4.26.1 here: https://docs.docker.com/desktop/release-notes/#4261""")
    print(f"#-> Available version {parsedDockerVersion} ok.", "\n")
    
checkDockerVersion("25.0.0")