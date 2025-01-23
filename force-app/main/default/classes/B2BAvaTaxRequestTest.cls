@IsTest
private class B2BAvaTaxRequestTest {
    @isTest
    static void testParseValidJson() {
        String jsonString = '{'+
            '"code": "INV12345",'+
            '"type": "SalesInvoice",'+
            '"companyCode": "XYZCorp",'+
            '"date": "2023-09-12",'+
            '"customerCode": "CUST001",'+
            '"customerUsageType": "CUST001",'+
            '"entityUseCode": "CUST001",'+
            '"purchaseOrderNo": "PO123456",'+
            '"currencyCode": "USD",'+
            '"exemptionNo": "EX123",'+
            '"reportingLocationCode": "EX123",'+
            '"discount": 10.0,'+
            '"salespersonCode": "SP001",'+
            '"businessIdentificationNo": "BIN123",'+
            '"description": "Sample Transaction",'+
            '"referenceCode": "Sample",'+
            '"commit": true,'+
            '"batchCode": "BATCH001",'+
            '"serviceMode": "BATCH001",'+
            '"exchangeRate": 1,'+
            '"exchangeRateEffectiveDate": "BATCH001",'+
            '"exchangeRateCurrencyCode": "BATCH001",'+
            '"posLaneCode": "BATCH001",'+
            '"isSellerImporterOfRecord": true,'+
            '"email": "test@mail.com",'+
            '"debugLevel": "Test",'+
            '"customerSupplierName": "Roger",'+
            '"dataSourceId": 123,'+
            '"deliveryTerms": "Test",'+
            '"taxOverride": { '+
                '"type": "TaxAmount", '+
                '"reason": "Discount Applied", '+
                '"taxAmount": 5.0, '+
                '"taxDate": "2023-09-12", '+
                '"taxAmountByTaxTypes": [{'+
                    '"taxTypeId": "123",'+
                    '"taxAmount": 1'+
                '}]'+
            '},'+
            '"parameters": [{'+
                '"name": "Roger",'+
                '"value": "1",'+
                '"unit": "1"'+
            '}],'+
            '"userDefinedFields": [{'+
                '"name": "Roger",'+
                '"value": "1"'+
            '}],'+
            '"lines": [{'+
                '"number": "1",'+
                '"quantity": 5.0,'+
                '"amount": 100.0,'+
                '"taxCode": "P0000000",'+
                '"description": "Item 1",'+
                '"taxIncluded": false,'+
                '"customerUsageType": "Item 1",'+
                '"entityUseCode": "Item 1",'+
                '"itemCode": "Item 1",'+
                '"exemptionCode": "Item 1",'+
                '"discounted": false,'+
                '"revenueAccount": "Item 1",'+
                '"ref1": "Item 1",'+
                '"ref2": "Item 1",'+
                '"businessIdentificationNo": "Item 1",'+
                '"hsCode": "Item 1",'+
                '"merchantSellerId": 1,'+
                '"merchantSellerIdentifier": "Item 1",'+
                '"marketplaceLiabilityType": "Item 1",'+
                '"originationDocumentId": "Item 1",'+
                '"originationSite": "Item 1",'+
                '"category": "Item 1",'+
                '"summary": "Item 1"'+
            '},'+
            '{'+
                '"number": "2",'+
                '"quantity": 3.0,'+
                '"amount": 50.0,'+
                '"taxCode": "P0000001",'+
                '"description": "Item 2",'+
                '"taxIncluded": true'+
            '}],'+
            '"addresses": {'+
                '"shipFrom": {'+
                    '"id": "98101",'+
                    '"transactionId": 98101,'+
                    '"boundaryLevel": "98101",'+
                    '"line1": "123 Main St",'+
                    '"line2": "Suite 100",'+
                    '"city": "Seattle",'+
                    '"region": "WA",'+
                    '"postalCode": "98101",'+
                    '"country": "US",'+
                    '"taxRegionId": 98101'+
                '},'+
                '"shipTo": {'+
                    '"line1": "456 Market St",'+
                    '"line2": "Apt 12",'+
                    '"city": "San Francisco",'+
                    '"region": "CA",'+
                    '"postalCode": "94105",'+
                    '"country": "US"'+
                '}'+
            '}'+
        '}';

        // Call the parse method on the JSON string
        B2BAvaTaxRequest request = B2BAvaTaxRequest.parse(jsonString);

        // Perform assertions to check the parsing
        System.assertEquals('INV12345', request.code);
        System.assertEquals('SalesInvoice', request.type);
        System.assertEquals('XYZCorp', request.companyCode);
        System.assertEquals('CUST001', request.customerCode);
        System.assertEquals('PO123456', request.purchaseOrderNo);
        System.assertEquals('USD', request.currencyCode);
        System.assertEquals('EX123', request.exemptionNo);
        System.assertEquals(10.0, request.discount);
        System.assertEquals('SP001', request.salespersonCode);
        System.assertEquals('BIN123', request.businessIdentificationNo);
        System.assertEquals('Sample Transaction', request.description);
        System.assertEquals('BATCH001', request.batchCode);

        // Assert taxOverride object
        System.assertEquals('TaxAmount', request.taxOverride.type);
        System.assertEquals('Discount Applied', request.taxOverride.reason);
        System.assertEquals(5.0, request.taxOverride.taxAmount);
        System.assertEquals('2023-09-12', request.taxOverride.taxDate);

        // Assert lines
        System.assertEquals(2, request.lines.size());

        // Check first line item
        System.assertEquals('1', request.lines[0].number_Z);
        System.assertEquals(5.0, request.lines[0].quantity);
        System.assertEquals(100.0, request.lines[0].amount);
        System.assertEquals('P0000000', request.lines[0].taxCode);
        System.assertEquals('Item 1', request.lines[0].description);
        System.assertEquals(false, request.lines[0].taxIncluded);

        // Check second line item
        System.assertEquals('2', request.lines[1].number_Z);
        System.assertEquals(3.0, request.lines[1].quantity);
        System.assertEquals(50.0, request.lines[1].amount);
        System.assertEquals('P0000001', request.lines[1].taxCode);
        System.assertEquals('Item 2', request.lines[1].description);
        System.assertEquals(true, request.lines[1].taxIncluded);

        // Assert addresses
        System.assertEquals('123 Main St', request.addresses.shipFrom.line1);
        System.assertEquals('Seattle', request.addresses.shipFrom.city);
        System.assertEquals('WA', request.addresses.shipFrom.region);
        System.assertEquals('98101', request.addresses.shipFrom.postalCode);
        System.assertEquals('US', request.addresses.shipFrom.country);

        System.assertEquals('456 Market St', request.addresses.shipTo.line1);
        System.assertEquals('San Francisco', request.addresses.shipTo.city);
        System.assertEquals('CA', request.addresses.shipTo.region);
        System.assertEquals('94105', request.addresses.shipTo.postalCode);
        System.assertEquals('US', request.addresses.shipTo.country);
    }
}