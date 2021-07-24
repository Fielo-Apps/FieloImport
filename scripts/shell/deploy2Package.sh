# !/bin/bash

rm -R .metadata/FieloImport && echo 'Folder FieloImport removed'

echo 'Converting Source'
sfdx force:source:convert -r force-app -d .metadata/FieloImport -n 'FieloImport'

echo "Deploying Converted Source to org"
sfdx force:mdapi:deploy --deploydir .metadata/FieloImport -w -1