@isTest
public class TestBImportController {

    @isTest
    static void getNamespace() {
        System.assertEquals('', BImportController.getNamespace(), 'Wrong namespaceprefix');
    }

    @isTest
    static void createImportRequest() {
        ImportRequest__c record = (ImportRequest__c) BImportController.createImportRequest();

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');
    }

    @isTest
    static void getImportRequest() {
        ImportRequest__c record = (ImportRequest__c) BImportController.createImportRequest();

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');

        record = (ImportRequest__c) BImportController.getImportRequest(record.Id);

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');
    }

    @isTest
    static void saveFile() {
        ImportRequest__c record = (ImportRequest__c) BImportController.createImportRequest();

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DefaultProgram'];

        Id fileId = BImportController.saveFile(
            record.Id,
            'DefaultProgram.json',
            EncodingUtil.base64Encode(sr.Body),
            'json'
        );

        ContentVersion cv = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id = :fileId];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :record.Id];

        System.assert(fileId != null);
        System.assertEquals('DefaultProgram.json', cv.Title, 'Wrong file title');
        System.assertEquals('DefaultProgram.json', cv.PathOnClient, 'Wrong file PathOnClient');
        System.assert(cdl != null, 'file should be linked with import request');
        System.assertEquals(record.Id, cdl.LinkedEntityId, 'Wrong file LinkedEntityId');
    }

    @isTest
    static void saveTheChunk() {
        ImportRequest__c record = (ImportRequest__c) BImportController.createImportRequest();

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DefaultProgram'];

        Id fileId = BImportController.saveTheChunk(
            record.Id,
            'DefaultProgram.json',
            EncodingUtil.base64Encode(sr.Body),
            'json',
            null
        );

        ContentVersion cv = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id = :fileId];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :record.Id];

        System.assert(fileId != null);
        System.assertEquals('DefaultProgram.json', cv.Title, 'Wrong file title');
        System.assertEquals('DefaultProgram.json', cv.PathOnClient, 'Wrong file PathOnClient');
        System.assert(cdl != null, 'file should be linked with import request');
        System.assertEquals(record.Id, cdl.LinkedEntityId, 'Wrong file LinkedEntityId');
    }

    @isTest
    static void appendToFile() {
        ImportRequest__c record = (ImportRequest__c) BImportController.createImportRequest();

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');

        String fileContents = '{"simple":"object"}';
        Integer fileLength = fileContents.length();
        String firstChunk = fileContents.substring(0, Integer.valueOf(fileLength/2));
        String secondChunk = fileContents.substring(Integer.valueOf(fileLength/2), fileLength);

        String errorMessage = '';
        Id fileId;
        try{
            fileId = BImportController.saveTheChunk(
                record.Id,
                'DefaultProgram.json',
                EncodingUtil.base64Encode(Blob.valueOf(firstChunk)),
                'json',
                null
            );

            fileId = BImportController.saveTheChunk(
                record.Id,
                'DefaultProgram.json',
                EncodingUtil.base64Encode(Blob.valueOf(secondChunk)),
                'json',
                fileId
            );
        } catch(Exception e) {
            errorMessage = e.getMessage();
        }

        System.assertEquals('', errorMessage, 'Exception thrown');

        ContentVersion cv = [SELECT Id, Title, PathOnClient, ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :fileId];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :record.Id];

        System.assert(fileId != null);
        System.assertEquals('DefaultProgram.json', cv.Title, 'Wrong file title');
        System.assertEquals('DefaultProgram.json', cv.PathOnClient, 'Wrong file PathOnClient');
        System.assert(cdl != null, 'file should be linked with import request');
        System.assertEquals(record.Id, cdl.LinkedEntityId, 'Wrong file LinkedEntityId');

        System.assertEquals(fileContents, cv.VersionData.toString(), 'Wrong file contents');
    }

    @isTest
    static void execute_validation() {
        ImportRequest__c record = (ImportRequest__c) BImportController.createImportRequest();

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DefaultProgram'];

        Id fileId = BImportController.saveTheChunk(
            record.Id,
            'DefaultProgram.json',
            EncodingUtil.base64Encode(sr.Body),
            'json',
            null
        );

        ContentVersion cv = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id = :fileId];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :record.Id];

        System.assert(fileId != null);
        System.assertEquals('DefaultProgram.json', cv.Title, 'Wrong file title');
        System.assertEquals('DefaultProgram.json', cv.PathOnClient, 'Wrong file PathOnClient');
        System.assert(cdl != null, 'file should be linked with import request');
        System.assertEquals(record.Id, cdl.LinkedEntityId, 'Wrong file LinkedEntityId');

        Test.startTest();
            BImportController.execute(record.Id, 'Validation');
        Test.stopTest();

        record = (ImportRequest__c) BImportController.getImportRequest(record.Id);

        System.assertEquals('Validation Succeeded', record.Status__c, 'Wrong import request status');
    }

    @isTest
    static void execute_import() {
        ImportRequest__c record = (ImportRequest__c) BImportController.createImportRequest();

        System.assertEquals('Draft', record.Status__c, 'Wrong status value');
        System.assertEquals(UserInfo.getUserId(), record.OwnerId, 'Wrong ownerid value');

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DefaultProgram'];

        Id fileId = BImportController.saveTheChunk(
            record.Id,
            'DefaultProgram.json',
            EncodingUtil.base64Encode(sr.Body),
            'json',
            null
        );

        ContentVersion cv = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id = :fileId];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :record.Id];

        System.assert(fileId != null);
        System.assertEquals('DefaultProgram.json', cv.Title, 'Wrong file title');
        System.assertEquals('DefaultProgram.json', cv.PathOnClient, 'Wrong file PathOnClient');
        System.assert(cdl != null, 'file should be linked with import request');
        System.assertEquals(record.Id, cdl.LinkedEntityId, 'Wrong file LinkedEntityId');

        Test.startTest();
            BImportController.execute(record.Id, 'Import');
        Test.stopTest();

        record = (ImportRequest__c) BImportController.getImportRequest(record.Id);

        System.assertEquals('Import Succeeded', record.Status__c, 'Wrong import request status');
    }
}
