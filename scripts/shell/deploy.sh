# !/bin/bash
if [ $# -eq 1 ]
then
    sfdx force:source:deploy -p force-app -u $1
else
    sfdx force:source:deploy -p force-app
fi