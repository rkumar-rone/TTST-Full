@IsTest
private with sharing class B2BAvaTaxResponseJSONTest {
    @IsTest
    static void parseTest() {
        
        String responseBody = '{' +
        '    "id": 85100913848595,'+
		'    "code": "f0b7688d-f1ce-4b62-866b-1290ea3d9f2b",'+
		'    "companyId": 1003008,'+
		'    "date": "2022-10-05",'+
		'    "status": "Saved",'+
		'    "type": "SalesInvoice",'+
		'    "batchCode": "",'+
		'    "currencyCode": "EUR",'+
		'    "exchangeRateCurrencyCode": "EUR",'+
		'    "customerUsageType": "",'+
		'    "entityUseCode": "",'+
		'    "customerVendorCode": "KLITEST",'+
		'    "customerCode": "KLITEST",'+
		'    "exemptNo": "",'+
		'    "reconciled": false,'+
		'    "locationCode": "DEFAULT",'+
		'    "reportingLocationCode": "DEFAULT",'+
		'    "purchaseOrderNo": "",'+
		'    "referenceCode": "",'+
		'    "salespersonCode": "",'+
		'    "taxOverrideType": "None",'+
		'    "taxOverrideAmount": 0.0,'+
		'    "taxOverrideReason": "",'+
		'    "totalAmount": 197.0,'+
		'    "totalExempt": 0.0,'+
		'    "totalDiscount": 0.0,'+
		'    "totalTax": 17.73,'+
		'    "totalTaxable": 197.0,'+
		'    "totalTaxCalculated": 17.73,'+
		'    "adjustmentReason": "NotAdjusted",'+
		'    "adjustmentDescription": "",'+
		'    "locked": false,'+
		'    "region": "",'+
		'    "country": "NL",'+
		'    "version": 1,'+
		'    "softwareVersion": "22.9.4.0",'+
		'    "originAddressId": 85100913848597,'+
		'    "destinationAddressId": 85100913848596,'+
		'    "exchangeRateEffectiveDate": "2022-10-05",'+
		'    "exchangeRate": 1.0,'+
		'    "isSellerImporterOfRecord": false,'+
		'    "description": "",'+
		'    "email": "",'+
		'    "businessIdentificationNo": "",'+
		'    "modifiedDate": "2022-10-10T10:41:36.5817281Z",'+
		'    "modifiedUserId": 1175259,'+
		'    "taxDate": "2022-10-05",'+
		'    "lines": ['+
		'        {'+
		'            "id": 85100913848601,'+
		'            "transactionId": 85100913848595,'+
		'            "lineNumber": "1",'+
		'            "boundaryOverrideId": 0,'+
		'            "customerUsageType": "",'+
		'            "entityUseCode": "",'+
		'            "description": "",'+
		'            "destinationAddressId": 85100913848596,'+
		'            "originAddressId": 85100913848597,'+
		'            "discountAmount": 0.0,'+
		'            "discountTypeId": 0,'+
		'            "exemptAmount": 0.0,'+
		'            "exemptCertId": 0,'+
		'            "exemptNo": "",'+
		'            "isItemTaxable": true,'+
		'            "isSSTP": false,'+
		'            "itemCode": "10072186-0001",'+
		'            "lineAmount": 197.0,'+
		'            "quantity": 1.0,'+
		'            "ref1": "0a97g000000086eAAA",'+
		'            "ref2": "",'+
		'            "reportingDate": "2022-10-05",'+
		'            "revAccount": "",'+
		'            "sourcing": "Origin",'+
		'            "tax": 17.7300,'+
		'            "taxableAmount": 197.0,'+
		'            "taxCalculated": 17.7300,'+
		'            "taxCode": "PB100000",'+
		'            "taxCodeId": 4328,'+
		'            "taxDate": "2022-10-05",'+
		'            "taxEngine": "",'+
		'            "taxOverrideType": "None",'+
		'            "businessIdentificationNo": "",'+
		'            "taxOverrideAmount": 0.0,'+
		'            "taxOverrideReason": "",'+
		'            "taxIncluded": false,'+
		'            "details": ['+
		'                {'+
		'                    "id": 85100913848634,'+
		'                    "transactionLineId": 85100913848601,'+
		'                    "transactionId": 85100913848595,'+
		'                    "addressId": 85100913848597,'+
		'                    "country": "NL",'+
		'                    "region": "NL",'+
		'                    "countyFIPS": "",'+
		'                    "stateFIPS": "",'+
		'                    "exemptAmount": 0.0000,'+
		'                    "exemptReasonId": 4,'+
		'                    "inState": true,'+
		'                    "jurisCode": "NL",'+
		'                    "jurisName": "NETHERLANDS",'+
		'                    "jurisdictionId": 200099,'+
		'                    "signatureCode": "",'+
		'                    "stateAssignedNo": "",'+
		'                    "jurisType": "CNT",'+
		'                    "jurisdictionType": "Country",'+
		'                    "nonTaxableAmount": 0.0000,'+
		'                    "nonTaxableRuleId": 0,'+
		'                    "nonTaxableType": "RateRule",'+
		'                    "rate": 0.090000,'+
		'                    "rateRuleId": 4129002,'+
		'                    "rateSourceId": 0,'+
		'                    "serCode": "",'+
		'                    "sourcing": "Origin",'+
		'                    "tax": 17.7300,'+
		'                    "taxableAmount": 197.0000,'+
		'                    "taxType": "Output",'+
		'                    "taxSubTypeId": "O",'+
		'                    "taxTypeGroupId": "InputAndOutput",'+
		'                    "taxName": "Reduced R",'+
		'                    "taxAuthorityTypeId": 45,'+
		'                    "taxRegionId": 205099,'+
		'                    "taxCalculated": 17.7300,'+
		'                    "taxOverride": 0.0000,'+
		'                    "rateType": "ReducedR",'+
		'                    "rateTypeCode": "R",'+
		'                    "taxableUnits": 197.0000,'+
		'                    "nonTaxableUnits": 0.0000,'+
		'                    "exemptUnits": 0.0000,'+
		'                    "unitOfBasis": "PerCurrencyUnit",'+
		'                    "isNonPassThru": false,'+
		'                    "isFee": false,'+
		'                    "reportingTaxableUnits": 197.0,'+
		'                    "reportingNonTaxableUnits": 0.0,'+
		'                    "reportingExemptUnits": 0.0,'+
		'                    "reportingTax": 17.73,'+
		'                    "reportingTaxCalculated": 17.73,'+
		'                    "avtUserBIN": "27152618",'+
		'                    "liabilityType": "Seller"'+
		'                }'+
		'            ],'+
		'            "nonPassthroughDetails": [],'+
		'            "lineLocationTypes": ['+
		'                {'+
		'                    "documentLineLocationTypeId": 85100913848603,'+
		'                    "documentLineId": 85100913848601,'+
		'                    "documentAddressId": 85100913848597,'+
		'                    "locationTypeCode": "ShipFrom"'+
		'                },'+
		'                {'+
		'                    "documentLineLocationTypeId": 85100913848604,'+
		'                    "documentLineId": 85100913848601,'+
		'                    "documentAddressId": 85100913848596,'+
		'                    "locationTypeCode": "ShipTo"'+
		'                }'+
		'            ],'+
		'            "parameters": ['+
		'                {'+
		'                    "name": "Transport",'+
		'                    "value": "Seller"'+
		'                },'+
		'                {'+
		'                    "name": "MerchantName",'+
		'                    "value": "KLUWER LAW INTERNATIONAL B.V"'+
		'                },'+
		'                {'+
		'                    "name": "MerchantVatId",'+
		'                    "value": "NL800910333B01"'+
		'                },'+
		'                {'+
		'                    "name": "IsMarketplace",'+
		'                    "value": "False"'+
		'                },'+
		'                {'+
		'                    "name": "IsTriangulation",'+
		'                    "value": "false"'+
		'                },'+
		'                {'+
		'                    "name": "IsGoodsSecondHand",'+
		'                    "value": "false"'+
		'                },'+
		'                {'+
		'                    "name": "MerchantEstablishmentCountry",'+
		'                    "value": "NL"'+
		'                }'+
		'            ],'+
		'            "hsCode": "",'+
		'            "costInsuranceFreight": 0.0,'+
		'            "vatCode": "NLSL090C",'+
		'            "vatNumberTypeId": 0'+
		'        }'+
		'    ],'+
		'    "addresses": ['+
		'        {'+
		'            "id": 85100913848596,'+
		'            "transactionId": 85100913848595,'+
		'            "boundaryLevel": "Zip5",'+
		'            "line1": "",'+
		'            "line2": "",'+
		'            "line3": "",'+
		'            "city": "",'+
		'            "region": "",'+
		'            "postalCode": "19083",'+
		'            "country": "NL",'+
		'            "taxRegionId": 205099'+
		'        },'+
		'        {'+
		'            "id": 85100913848597,'+
		'            "transactionId": 85100913848595,'+
		'            "boundaryLevel": "Zip5",'+
		'            "line1": "",'+
		'            "line2": "",'+
		'            "line3": "",'+
		'            "city": "",'+
		'            "region": "",'+
		'            "postalCode": "4104 AM",'+
		'            "country": "NL",'+
		'            "taxRegionId": 205099'+
		'        }'+
		'    ],'+
		'    "locationTypes": ['+
		'        {'+
		'            "documentLocationTypeId": 85100913848599,'+
		'            "documentId": 85100913848595,'+
		'            "documentAddressId": 85100913848597,'+
		'            "locationTypeCode": "ShipFrom"'+
		'        },'+
		'        {'+
		'            "documentLocationTypeId": 85100913848600,'+
		'            "documentId": 85100913848595,'+
		'            "documentAddressId": 85100913848596,'+
		'            "locationTypeCode": "ShipTo"'+
		'        }'+
		'    ],'+
		'    "summary": ['+
		'        {'+
		'            "country": "NL",'+
		'            "region": "NL",'+
		'            "jurisType": "Country",'+
		'            "jurisCode": "NL",'+
		'            "jurisName": "NETHERLANDS",'+
		'            "taxAuthorityType": 45,'+
		'            "stateAssignedNo": "",'+
		'            "taxType": "Output",'+
		'            "taxSubType": "O",'+
		'            "taxName": "Reduced R",'+
		'            "rateType": "ReducedR",'+
		'            "taxable": 197.00,'+
		'            "rate": 0.090000,'+
		'            "tax": 17.73,'+
		'            "taxCalculated": 17.73,'+
		'            "nonTaxable": 0.00,'+
		'            "exemption": 0.00'+
		'        }'+
		'    ]'+
		'}';
        B2BAvaTaxResponseJSON responseModel;

        Test.startTest();
        responseModel = B2BAvaTaxResponseJSON.parse(responseBody);
        Test.stopTest();

        System.assert(responseModel != null);
    }
}