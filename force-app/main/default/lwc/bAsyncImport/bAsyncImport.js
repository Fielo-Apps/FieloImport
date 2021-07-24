import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Styles loader
import { loadStyle } from 'lightning/platformResourceLoader';
import asyncStyle from '@salesforce/resourceUrl/bAsyncImport';

// Controllers
import createImportRequest from '@salesforce/apex/BImportController.createImportRequest';
import getImportRequest from '@salesforce/apex/BImportController.getImportRequest';
import execute from '@salesforce/apex/BImportController.execute';
import saveTheChunk from '@salesforce/apex/BImportController.saveTheChunk';
import getNamespace from '@salesforce/apex/BImportController.getNamespace';

const MAX_FILE_SIZE = 4500000;
const CHUNK_SIZE = 750000;

const VALIDATE_FILE = 'Validation';
const IMPORT_FILE = 'Import';

const Status = {
    DRAFT: 'Draft',
    IN_PROGRESS: 'In Progress',
    VALIDATION_FAIL: 'Validation Failed',
    VALIDATION_SUCCESS: 'Validation Succeeded',
    PENDING: 'Pending',
    IMPORT_SUCCESS: 'Import Succeeded',
    IMPORT_FAIL: 'Import Failed'
}

export default class BAsyncImport extends LightningElement {
    fileUploaded;
    fileId;
    fileContent;
    @track importRecord;

    @track recordURL;

    @track fileSize;
    @track fileName;
    @track action;
    @track status = 'Waiting for file';
    @track isProcessing = false;
    @track isReady = false;
    @track isValid = false;
    @track fileSelected = false;
    @track done = false;
    @track output;

    fields = {
        STATUS: 'Status__c',
        DETAILS: 'Details__c',
        DURATION: 'Duration__c',
        SOQL: 'SOQLs__c'
    };

    namespacePrefix;

    connectedCallback() {
        if (document.querySelector('link[href="' + asyncStyle + '"]') === null) {
            Promise.all([
                loadStyle(this, asyncStyle)
            ]);
        }
        this.getNamespacePrefix();
    }

    async getNamespacePrefix() {
        this.namespacePrefix = await getNamespace();

        console.log(`namespacePrefix: ${this.namespacePrefix}`);

        if (this.namespacePrefix) {
            this.fields = Object.keys(this.fields).reduce((map, field) => {
                map[field] = `${this.namespacePrefix}${this.fields[field]}`
                return map;
            }, {});
        }

        console.log(`fields: ${JSON.stringify(this.fields, null, 2)}`);
    }

    readFile(event) {
        if(event.target.files.length > 0) {
            this.fileUploaded = event.target.files[0];
            this.fileName = event.target.files[0].name;
        }
        var fileCon = this.fileUploaded;
        this.fileSize = this.formatBytes(fileCon.size, 2);
        this.fileSize = this.formatBytes(fileCon.size, 2);
        if (fileCon.size > MAX_FILE_SIZE) {
            let message = 'File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + fileCon.size;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            return;
        }
        var reader = new FileReader();
        reader.onload = function() {
            this.fileContent = reader.result.match(/,(.*)$/)[1];
            this.status = 'File selected';
            this.fileSelected = true;
        }.bind(this);
        reader.readAsDataURL(fileCon);
    }

    handleValidate() {
        this.output = null;
        this.recordURL = null;
        this.action = VALIDATE_FILE;
        this.execute();
    }

    async execute() {
        if (this.fileContent && this.fileContent.length > 0) {
            this.status = `${this.action} started`;
            this.isProcessing = true;
            this.startProgress();
            if (!this.importRecord) {
                this.importRecord = await createImportRequest();
            }
            console.log(`this.importRecord: ${JSON.stringify(this.importRecord, null, 2)}`);
            if(this.action == VALIDATE_FILE) {
                this.upload();
            } else {
                this.importFile();
            }
        } else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Select a file to validate',
                variant: 'error'
            }));
        }
    }

    handleImport() {
        this.output = null;
        this.recordURL = null;
        this.action = IMPORT_FILE;
        this.execute();
    }

    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    upload(){
        var fromPos = 0;
        var toPos = Math.min(this.fileContent.length, fromPos + CHUNK_SIZE);

        this.uploadChunk(this.fileUploaded, this.fileContent, fromPos, toPos);
    }

    async uploadChunk(file, fileContents, fromPos, toPos){
        try {
            this.status = `Uploading file`;
            var chunk = fileContents.substring(fromPos, toPos);

            var result = await saveTheChunk({
                parentId: this.importRecord.Id,
                fileName: file.name,
                base64Data: encodeURIComponent(chunk),
                contentType: file.type,
                fileId: this.fileId
            });

            this.fileId = result;
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
            if (fromPos < toPos) {
                this.uploadChunk(file, fileContents, fromPos, toPos);
            }else{
                this.importFile();
            }
        } catch(e) {
            console.error(e);
        }
    }

    async importFile(){
        await execute({requestId: this.importRecord.Id, action: this.action});
        this.checkStatus();
    }

    _interval;
    @track _progress = 0;

    startProgress() {
        if (!this._interval) {
            this._interval = setInterval(() => {
                this._progress = this._progress === 100 ? 0 : this._progress + 2;
            }, 20);
        }
    }

    stopProgress() {
        if (this._interval) {
            clearInterval(this._interval);
            this._interval = null;
        }
    }

    async checkStatus() {
        try{
            this.importRecord = await getImportRequest({requestId: this.importRecord.Id});
            console.log(`this.importRecord: ${JSON.stringify(this.importRecord, null, 2)}`);
            this.updateStatus();
        } catch(e) {
            console.error(e);
        }
    }

    updateStatus() {
        switch (this.importRecord[this.fields.STATUS]) {
            case Status.DRAFT:
            case Status.IN_PROGRESS:
            case Status.PENDING:
                setTimeout(this.checkStatus.bind(this), 3000);
                this.status = `${this.action} status: ${this.importRecord[this.fields.STATUS]}`;
                break;

            case Status.VALIDATION_FAIL:
            case Status.IMPORT_FAIL:
                this.showDetails = true;
            case Status.VALIDATION_SUCCESS:
            case Status.IMPORT_SUCCESS:
                this.status = `${this.importRecord[this.fields.STATUS]}`;
                this.output = JSON.stringify(JSON.parse(this.importRecord[this.fields.DETAILS]), null, 2);
                this.isReady = this.importRecord[this.fields.STATUS] == Status.VALIDATION_SUCCESS ||
                    this.importRecord[this.fields.STATUS] == Status.IMPORT_SUCCESS;
                if (this.action == VALIDATE_FILE) {
                    this.isValid = this.importRecord[this.fields.STATUS] == Status.VALIDATION_SUCCESS;
                }
                if (this.action == IMPORT_FILE) {
                    this.done = this.importRecord[this.fields.STATUS] == Status.IMPORT_SUCCESS;
                }
                this.isProcessing = false;
                this.recordURL = `/${this.importRecord.Id}`;
                this.stopProgress();
                break;
        }
    }

    @track showDetails = false;
    handleShowDetail() {
        this.showDetails = true;
    }

    handleHideDetail() {
        this.showDetails = false;
    }

    @api
    get duration() {
        return this.importRecord && this.importRecord[this.fields.DURATION] || 0;
    }

    @api
    get queries() {
        return this.importRecord && this.importRecord[this.fields.SOQL] || 0;
    }

    @api
    get disableValidate() {
        return this.isProcessing || this.done || !this.fileSelected;
    }

    @api
    get disableImport() {
        return !this.isValid || !this.isReady || this.isProcessing || this.done || !this.fileSelected;
    }
}