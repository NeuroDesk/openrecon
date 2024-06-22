# Validate JSON file against OpenRecon schema and write Dockerfile
jsonFilePath    = 'OpenReconLabel.json'
schemaFilePath  = '../OpenReconSchema_1.1.0.json'
dockerfilePath  = 'OpenRecon.dockerfile'
baseDockerImage = 'stebo85/niimath-test'

import json
import jsonschema
import base64
import os

def validateJson(jsonFilePath, schemaFilePath):
    try:
        # Load the JSON data from the file
        with open(jsonFilePath, 'r') as jsonFile:
            jsonData = json.load(jsonFile)

        # Load the JSON schema from the file
        with open(schemaFilePath, 'r') as schemaFile:
            schemaData = json.load(schemaFile)

        # Create a JSON Schema validator
        validator = jsonschema.Draft7Validator(schemaData)

        # Validate the JSON data against the schema
        errors = list(validator.iter_errors(jsonData))

        if not errors:
            print("JSON is valid against the schema.")
            return True
        else:
            print("JSON is not valid against the schema. Errors:")
            for error in errors:
                print(error)
            return False
    
    except Exception as e:
        print(f"An error occurred: {e}")

# Write Dockerfile
if validateJson(jsonFilePath, schemaFilePath):
    with open(jsonFilePath, 'r') as jsonFile:
        jsonData = json.load(jsonFile)
    jsonString = json.dumps(jsonData, indent=2)
    encodedJson = base64.b64encode(jsonString.encode('utf-8')).decode('utf-8')

    with open(dockerfilePath, 'w') as file:
        labelName = 'com.siemens-healthineers.magneticresonance.openrecon.metadata:1.1.0'
        labelStr = 'LABEL "' + labelName + '"="' + encodedJson + '"'

        file.writelines('FROM ' + baseDockerImage)
        file.writelines('\n' + labelStr)
    print('Wrote Dockerfile:', os.path.abspath(dockerfilePath))
else:
    raise Exception('Not writing Dockerfile because JSON is not valid')

# Build Docker image, save to a .tar file, and package into a .zip file for OpenRecon
# The documentation must be a valid PDF!
docsFile = 'docs.pdf'

# Filename must match information contained in the JSON
version = jsonData['general']['version']
vendor  = jsonData['general']['vendor']
name    = jsonData['general']['name']['en']

# Check documentation file exists
if not os.path.isfile(docsFile):
    raise Exception('Could not find documentation file: ' + docsFile)

# Check 7-zip exists
zipExe = '/usr/bin/7z'

if not os.path.isfile(zipExe):
    raise Exception('Could not find 7-Zip executable: ' + zipExe + '\nPlease download and install 7-Zip')

dockerImagename = ('OpenRecon_' + vendor + '_' + name + ':' +  'V' + version).lower()
baseFilename    =  'OpenRecon_' + vendor + '_' + name +       '_V' + version

import subprocess
import shutil

try:
    # Build Docker image docker buildx build --platform linux/amd64
    print('Attempting to create Docker image with tag:', dockerImagename, '...')
    output = subprocess.check_output(['docker', 'buildx', 'build', '--platform', 'linux/amd64', '--no-cache', '--progress=plain', '-t', dockerImagename, '-f', dockerfilePath, './'], stderr=subprocess.STDOUT)
    print('Docker build output:\n' + output.decode('utf-8'))

    # Save Docker image to a .tar file
    print('Saving Docker image file with name:', baseFilename + '.tar', '...')
    output = subprocess.check_output(['docker', 'save', '-o', baseFilename + '.tar', dockerImagename], stderr=subprocess.STDOUT)
    print('Docker save output:\n' + output.decode('utf-8'))

    # Copy documentation file with appropriate filename
    print('Copying documentation to file with name:', baseFilename + '.pdf', '...')
    try:
        shutil.copy(docsFile, baseFilename + '.pdf')
        print(f'File copied from {docsFile} to {baseFilename}.pdf')
    except IOError as e:
        print(f'An error occurred: {e}')

    # Zip into a package
    print('Packaging files into zip with name:', baseFilename + '.zip', '...')
    output = subprocess.check_output([zipExe, 'a', '-tzip', '-mm=Deflate', baseFilename + '.zip', baseFilename + '.tar', baseFilename + '.pdf'], stderr=subprocess.STDOUT)
    print('Zip packaging output:\n' + output.decode('utf-8'))

    print('Moving file to archive storage:', baseFilename + '.zip', '...')
    output = subprocess.check_output(['mv', baseFilename + '.zip', '/storage/openrecon/' + baseFilename + '.zip'], stderr=subprocess.STDOUT)
    print('moved file to /storage/openrecon')



except subprocess.CalledProcessError as e:
    # If the command returns a non-zero exit status, it will raise a CalledProcessError
    print('Command failed with return code:', e.returncode)
    print('Error output:\n' + e.output.decode('utf-8'))

