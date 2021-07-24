# !/bin/bash

sfdx force:source:deploy -m ApexClass:BImportController,ApexClass:TestBImportController && sfdx force:apex:test:run -y -t TestBImportController