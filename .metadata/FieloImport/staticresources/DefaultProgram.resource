{
  "exportType" : "update",
  "configObjects" : [ {
    "apiName" : "fieloplt__program__c",
    "fieldsToExclude" : "fieloplt__image__c,fieloplt__externalurl__c,fieloplt__currentagreement__c,fieloplt__criteriafields__c,fieloplt__consentsummary__c,fieloplt__relatedsegments__c"
  }, {
    "apiName" : "fieloplt__agreement__c",
    "fieldsToExclude" : "fieloplt__status__c"
  }, {
    "apiName" : "fieloplt__badge__c",
    "fieldsToExclude" : "fieloplt__status__c,fieloplt__image__c,fieloplt__externalurl__c"
  }, {
    "apiName" : "fieloplt__programpointtype__c",
    "fieldsToExclude" : "fieloplt__uniquekey__c",
    "fieldsToExcludeModel" : "fieloplt__uniquekey__c"
  }, {
    "apiName" : "fieloplt__reward__c",
    "fieldsToExclude" : "fieloplt__image__c,fieloplt__externalurl__c"
  }, {
    "apiName" : "fieloplt__promotion__c",
    "fieldsToExclude" : "fieloplt__status__c,fieloplt__image__c,fieloplt__externalurl__c, fieloplt__currentagreement__c,fieloplt__activationdate__c",
    "fieldsToExcludeModel" : "fieloplt__startdate__c,fieloplt__enddate__c"
  }, {
    "apiName" : "fieloplt__challenge__c",
    "fieldsToExclude" : "fieloplt__status__c,fieloplt__image__c,fieloplt__externalurl__c,fieloplt__currentagreement__c,fieloplt__isprocessed__c,fieloplt__levelsummary__c",
    "fieldsToExcludeModel" : "fieloplt__startdate__c,fieloplt__enddate__c"
  }, {
    "apiName" : "fieloplt__action__c",
    "fieldsToExclude" : "fieloplt__rulesquantity__c,fieloplt__missionsquantity__c,fieloplt__criteriafields__c,fieloplt__templatesquantity__c"
  }, {
    "apiName" : "fieloplt__mission__c",
    "fieldsToExcludeModel" : "fieloplt__startdate__c,fieloplt__enddate__c"
  }, {
    "apiName" : "fieloplt__level__c",
    "fieldsToExclude" : "fieloplt__image__c,fieloplt__externalurl__c"
  }, {
    "apiName" : "fieloplt__cap__c",
    "fieldsToExclude" : "fieloplt__cappingsummary__c"
  } ],
  "migrationRecords" : [ {
    "objectAPIName" : "fieloplt__program__c",
    "records" : [ {
      "fieldsValues" : [ {
        "apiName" : "name",
        "value" : "Default"
      }, {
        "apiName" : "fieloplt__capadjustmenttransactions__c",
        "value" : "false"
      }, {
        "apiName" : "fieloplt__enablecomplexmaximization__c",
        "value" : "false"
      }, {
        "apiName" : "fieloplt__enableincentivescalculator__c",
        "value" : "false"
      }, {
        "apiName" : "fieloplt__externalid__c",
        "value" : "00D5e000002S0bb-a0l5e000001onID"
      }, {
        "apiName" : "fieloplt__onlinetransactionprocessing__c",
        "value" : "true"
      }, {
        "apiName" : "fieloplt__requestbudgetauthorization__c",
        "value" : "false"
      }, {
        "apiName" : "fieloplt__requestmemberauthorization__c",
        "value" : "false"
      }, {
        "apiName" : "fieloplt__requestredemptionauthorization__c",
        "value" : "false"
      }, {
        "apiName" : "fieloplt__requestuser__c",
        "value" : "false"
      } ],
      "relatedList" : [ {
        "objectAPIName" : "fieloplt__programpointtype__c",
        "records" : [ {
          "fieldsValues" : [ {
            "apiName" : "fieloplt__auditpoints__c",
            "value" : "false"
          }, {
            "apiName" : "fieloplt__expirationmode__c",
            "value" : "Partial"
          }, {
            "apiName" : "fieloplt__externalid__c",
            "value" : "00D5e000002S0bbEAC-a0l5e000001onIDAAY-FieloPoint"
          }, {
            "apiName" : "fieloplt__pointtype__c.fieloplt__externalid__c",
            "value" : "FieloPoint",
            "refObject" : "fieloplt__pointtype__c"
          }, {
            "apiName" : "fieloplt__program__c.fieloplt__externalid__c",
            "value" : "00D5e000002S0bb-a0l5e000001onID",
            "refObject" : "fieloplt__program__c"
          }, {
            "apiName" : "fieloplt__requestpointapproval__c",
            "value" : "false"
          } ],
          "relatedList" : [ ]
        } ]
      }, {
        "objectAPIName" : "fieloplt__reward__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__badge__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__agreement__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__programassignment__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__segment__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__challenge__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__level__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__promotion__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__kpidomain__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__emailtemplate__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__emailcampaign__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__cap__c",
        "records" : [ ]
      } ]
    } ]
  }, {
    "objectAPIName" : "fieloplt__pointtype__c",
    "records" : [ {
      "fieldsValues" : [ {
        "apiName" : "name",
        "value" : "Point"
      }, {
        "apiName" : "fieloplt__conversionmodefield__c",
        "value" : "FieloPLT__PointConversionMode__c"
      }, {
        "apiName" : "fieloplt__conversionvaluefield__c",
        "value" : "FieloPLT__ConversionValue__c"
      }, {
        "apiName" : "fieloplt__decimalsnumber__c",
        "value" : "0"
      }, {
        "apiName" : "fieloplt__externalid__c",
        "value" : "FieloPoint"
      }, {
        "apiName" : "fieloplt__generatepayout__c",
        "value" : "false"
      }, {
        "apiName" : "fieloplt__memberbalancefield__c",
        "value" : "FieloPLT__Points__c"
      }, {
        "apiName" : "fieloplt__monthsuntilexpirationfield__c",
        "value" : "FieloPLT__MonthsUntilExpiration__c"
      }, {
        "apiName" : "fieloplt__pointexpirationdatefield__c",
        "value" : "FieloPLT__PointExpirationDate__c"
      }, {
        "apiName" : "fieloplt__pointexpirationmodefield__c",
        "value" : "FieloPLT__PointExpirationMode__c"
      }, {
        "apiName" : "fieloplt__pointreflectionfield__c",
        "value" : "FieloPLT__PointReflection__c"
      }, {
        "apiName" : "fieloplt__recordfieldnamefield__c",
        "value" : "FieloPLT__RecordFieldName__c"
      }, {
        "apiName" : "fieloplt__redemptionbalancefield__c",
        "value" : "FieloPLT__Points__c"
      }, {
        "apiName" : "fieloplt__redemptionitembalancefield__c",
        "value" : "FieloPLT__Points__c"
      }, {
        "apiName" : "fieloplt__rewardbalancefield__c",
        "value" : "FieloPLT__Points__c"
      }, {
        "apiName" : "fieloplt__status__c",
        "value" : "Active"
      }, {
        "apiName" : "fieloplt__transactionbalancefield__c",
        "value" : "FieloPLT__Points__c"
      }, {
        "apiName" : "fieloplt__transactionexpirationdatefield__c",
        "value" : "FieloPLT__PointExpirationDate__c"
      } ],
      "relatedList" : [ ]
    } ]
  } ],
  "segmentsCombinations" : [ ]
}