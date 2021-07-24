public class BImportController {

    @AuraEnabled
    public static string getNamespace(){
        try {
            List<Organization> orgDef = (List<Organization>) Database.query('SELECT NamespacePrefix FROM Organization');
            return orgDef.isEmpty() ? '' : String.isNotBlank(orgDef.get(0).NamespacePrefix) ? (orgDef.get(0).NamespacePrefix + '__') : '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static object createImportRequest(){
        try {
            List<ImportRequest__c> records = (List<ImportRequest__c>) Database.query(
                'SELECT Id FROM ImportRequest__c WHERE Status__c = \'Draft\' AND OwnerId = \''+UserInfo.getUserId()+'\''
            );

            if (records.isEmpty()) {
                records.add(
                    new ImportRequest__c(
                        Status__c = 'Draft',
                        OwnerId = UserInfo.getUserId()
                    )
                );
                insert records;
            }

            records = (List<ImportRequest__c>) Database.query(
                'SELECT ' + String.join(new List<String>(SObjectType.ImportRequest__c.fields.getMap().keySet()), ',') + ' FROM ImportRequest__c WHERE Id IN :records'
            );

            return records.get(0);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static object getImportRequest(Id requestId){
        try {
            List<ImportRequest__c> records = (List<ImportRequest__c>) Database.query(
                'SELECT ' + String.join(new List<String>(SObjectType.ImportRequest__c.fields.getMap().keySet()), ',') + ' FROM ImportRequest__c WHERE Id = :requestId'
            );

            return records.get(0);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        ContentVersion cv = new ContentVersion();
        if (Schema.sObjectType.ContentVersion.fields.Title.isCreateable()) {
            cv.Title = fileName;
        }
        if (Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()) {
            cv.PathOnClient = fileName;
        }
        if (Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()) {
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
        }
        if (Schema.sObjectType.ContentVersion.fields.IsMajorVersion.isCreateable()) {
            cv.IsMajorVersion = false;
            cv.IsMajorVersion = false;
        }
        if (Schema.sObjectType.ContentVersion.isCreateable()) {
            insert cv;
        } else {
            throw new FieloPLT.FieloException('Cannot insert ContentVersion');
        }

        ContentDocumentLink cdl = new ContentDocumentLink();
        if (Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()) {
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        }
        if (Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
            cdl.LinkedEntityId = parentId;
        }
        if (Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()) {
            cdl.ShareType = 'V';
        }
        if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            insert cdl;
        } else {
            throw new FieloPLT.FieloException('Cannot insert ContentDocumentLink');
        }

        return cv.Id;
    }

    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        Savepoint sp = Database.setSavepoint();
        try{
            if (String.isBlank(fileId)) {
	            fileId = saveFile(parentId, fileName, base64Data, contentType);
	        } else {
	            fileId = appendToFile(parentId, fileId, base64Data);
	        }
            update new ImportRequest__c(
                Id = parentId,
                Status__c = 'Pending',
                File__c = fileId
            );
        	return Id.valueOf(fileId);
        } catch (DmlException e) {
            Database.rollback( sp );
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            Database.rollback( sp );
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Id appendToFile(Id parentId, Id fileId, String base64Data) {
        if (Schema.sObjectType.ContentVersion.isAccessible()) {
            ContentVersion existingCV = [SELECT Id, VersionData, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id = :fileId ORDER BY CreatedDate DESC LIMIT 1];

            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

            String existingBody = EncodingUtil.base64Encode(existingCV.VersionData);

            ContentVersion cv = new ContentVersion();
            if (Schema.sObjectType.ContentVersion.fields.Title.isCreateable()) {
                cv.Title = existingCV.Title;
            }
            if (Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()) {
                cv.PathOnClient = existingCV.Title;
            }
            if (Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()) {
                cv.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
            }
            if (Schema.sObjectType.ContentVersion.fields.IsMajorVersion.isCreateable()) {
                cv.IsMajorVersion = true;
            }

            if (Schema.sObjectType.ContentDocument.isDeletable()) {
                delete [SELECT Id FROM ContentDocument WHERE Id = :existingCV.ContentDocumentId];
            }
            if (Schema.sObjectType.ContentVersion.isCreateable()) {
                insert cv;
            } else {
                throw new FieloPLT.FieloException('Cannot insert ContentVersion');
            }

            ContentDocumentLink cdl = new ContentDocumentLink();
            if (Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()) {
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            }
            if (Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
                cdl.LinkedEntityId = parentId;
            }
            if (Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()) {
                cdl.ShareType = 'V';
            }
            if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                insert cdl;
            } else {
                throw new FieloPLT.FieloException('Cannot insert ContentDocumentLink');
            }

            return cv.Id;
        } else {
            throw new FieloPLT.FieloException('Cannot insert ContentVersion');
        }
    }

    @AuraEnabled
    public static void execute(Id requestId, String action){
        try {
            update new ImportRequest__c(
                Id = requestId,
                Status__c = 'In Progress'
            );
            importFile(requestId, action);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @Future
    public static void importFile(Id requestId, String action) {
        try {
            Long startTime = System.currentTimeMillis();

            List<ImportRequest__c> records = (List<ImportRequest__c>) Database.query(
                'SELECT ' + String.join(new List<String>(SObjectType.ImportRequest__c.fields.getMap().keySet()), ',') + ' FROM ImportRequest__c WHERE Id = :requestId'
            );

            Id fileId = Id.valueOf(records.get(0).File__c);

            List<ContentVersion> cvs = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :records.get(0).File__c];

            records.get(0).Details__c = FieloPLT.MigrationService.importRecords(
                cvs.get(0).VersionData.toString(),
                true,
                new Map<String, map<String, String>>(),
                action != 'Import'
            );

            Map<String, Object> result = (Map<String,Object>) JSON.deserializeUntyped(records.get(0).Details__c);

            records.get(0).Status__c = result.containsKey('success') && Boolean.valueOf(result.get('success')) ?
                action == 'Import' ? 'Import Succeeded' : 'Validation Succeeded' :
                action == 'Import' ? 'Import Failed' : 'Validation Failed';

            Long endTime = System.currentTimeMillis();

            records.get(0).Duration__c = (endTime - startTime).intValue();
            records.get(0).SOQLs__c = Limits.getQueries();

            update records;
        } catch(Exception e) {
            update new ImportRequest__c(
                Id = requestId,
                Details__c = JSON.serialize(new Map<String, String>{
                    'error' => e.getMessage(),
                    'stackTrace' => e.getStackTraceString()
                }),
                Duration__c = Limits.getCpuTime(),
                SOQLs__c = Limits.getQueries(),
                Status__c = action == 'Import' ? 'Import Failed' : 'Validation Failed'
            );
        }
    }
}
