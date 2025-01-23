/**
 * @description       : Test Class for B2BAvalaraTaxUtil
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
private class B2BAvalaraTaxUtilTest {

    @testSetup 
    static void setup() {
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        
        System.runAs(adminUser){    
            BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
            Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
            ContactPointAddress testCPA = SIB_TestDataFactory.createShippingCPA(testAccount,true);
            WebStore testWebStore = SIB_TestDataFactory.createWebStore(true);
            Contact testContact = SIB_TestDataFactory.createContact(testAccount,true);
            WebCart testWebCart = SIB_TestDataFactory.createCart(testContact,adminUser,testWebStore,true);
            CartDeliveryGroup testCDG = SIB_TestDataFactory.createCartDeliveryGroup(testWebCart,true);
            Campaign testCampaign = new Campaign(Name = 'Test Campaign', 
                Seats_Available__c = 10,
                Training_Location_Street__c = 'Street1',
                Training_Location_City__c = 'Mojave',
                Training_Location_State__c = 'CA',
                Training_Location_Country__c = 'United States',
                Training_Location_Zip_Code__c = '90251',
                Account__c  = testAccount.Id,
                Delivery_Format__c = SIB_Constants.DELIVERY_FORMAT_IN_PERSON);
            insert testCampaign;

            Campaign testCampaign2 = new Campaign(Name = 'Test Campaign2', 
                Seats_Available__c = 10,
                Training_Location_Street__c = 'Street1',
                Training_Location_City__c = 'Mojave',
                Training_Location_State__c = 'CA',
                Training_Location_Country__c = 'United States',
                Training_Location_Zip_Code__c = '90251',
                Account__c  = testAccount.Id);
            insert testCampaign2;

            Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
            insert testSession;
            
            Product2 product = new Product2(
                IsActive = true, 
                Name = 'Test Product', 
                StockKeepingUnit = 'TestSKU', 
                Description = 'Test Description',
                TTS_Event__c = testCampaign.Id,
                Product_Group__c = SIB_Constants.PRODUCT_GROUP_PUBLIC_COURSE
            );
            insert product;

            Product2 product2 = new Product2(
                IsActive = true, 
                Name = 'Test Product2', 
                StockKeepingUnit = 'TestSKU2', 
                Description = 'Test Description',
                TTS_Event__c = testCampaign2.Id,
                Product_Group__c = SIB_Constants.PRODUCT_GROUP_PUBLIC_COURSE
            );
            insert product2;

            CartItem cartItem = new CartItem(
                CartId = testWebCart.id, 
                Sku = 'TestSKU',
                Quantity = 3.0,
                Type = 'Product', 
                Name = 'TestProduct', 
                CurrencyIsoCode = 'USD',
                Product2Id = product.id,
                CartDeliveryGroupId = testCDG.Id);
            insert cartItem;

            CartItem cartItem2 = new CartItem(
                CartId = testWebCart.id, 
                Sku = 'TestSKU2',
                Quantity = 3.0,
                Type = 'Product', 
                Name = 'TestProduct2', 
                CurrencyIsoCode = 'USD',
                Product2Id = product2.id,
                CartDeliveryGroupId = testCDG.Id);
            insert cartItem2;

            CartItem cartItem3 = new CartItem(
                CartId = testWebCart.Id, 
                Sku = 'TestSKU3',
                Quantity = 3.0,
                Type = 'Product', 
                Name = 'TestProduct3', 
                CurrencyIsoCode = 'USD',
                Product2Id = product.id,
                CartDeliveryGroupId = testCDG.Id);
            insert cartItem3;

            CartItemPriceAdjustment testCartItemPA = new CartItemPriceAdjustment(
                CartItemId = cartItem.Id,
                Name = 'Test Cart PA',
                AdjustmentValue = 20,
                TotalAmount = 20,
                AdjustmentSource = 'Promotion',
                AdjustmentType = 'AdjustmentAmount',
                AdjustmentTargetType = 'Item');
            insert testCartItemPA;
            CartTax testCartTax = new CartTax(
                Amount = 200,
                CartItemId = cartItem.Id,
                Name = 'Test',
                TaxCalculationDate =Date.today(),
                TaxType= 'Actual',
                CartItemPriceAdjustmentId = testCartItemPA.Id );
            insert testCartTax;

            CartTax testCartTax2 = new CartTax(
                Amount = 200,
                CartItemId = cartItem2.Id,
                Name = 'Test',
                TaxCalculationDate =Date.today(),
                TaxType= 'Actual' );
            insert testCartTax2;

            CartValidationOutput testCVO = new CartValidationOutput(
                CartId = testWebCart.Id,
                RelatedEntityId = cartItem.Id, 
                Name = 'Test Validation',
                Type = 'Taxes',
                Level = 'Info' ,
                Message = 'Test Message');
            insert testCVO;        
        }
      
    }

    @isTest
    static void testCalculateTaxes(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201)); 

        String cartId = [SELECT Id FROM WebCart WHERE Name =: 'Cart'].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;

        CartExtension.Cart cart = CartExtension.CartTestUtil.getCart(cartId);
        CartExtension.CartCalculateCalculatorRequest request = new CartExtension.CartCalculateCalculatorRequest(cart, CartExtension.OptionalBuyerActionDetails.empty());
        Test.startTest();
         Map<String,B2BAvalaraTaxModel> result  = B2BAvalaraTaxUtil.calculateTaxes(cart, cartId, accountId,'USD', SIB_Constants.TAX_TYPE_SALESORDER);
        Test.stopTest();

    }

    @isTest
    static void testCalculateTaxesException(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400)); 

        String cartId = [SELECT Id FROM WebCart WHERE Name =: 'Cart'].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;

        CartExtension.Cart cart = CartExtension.CartTestUtil.getCart(cartId);
        CartExtension.CartCalculateCalculatorRequest request = new CartExtension.CartCalculateCalculatorRequest(cart, CartExtension.OptionalBuyerActionDetails.empty());
        Test.startTest();
         try{
            Map<String,B2BAvalaraTaxModel> result  = B2BAvalaraTaxUtil.calculateTaxes(cart, cartId, accountId,'USD', SIB_Constants.TAX_TYPE_SALESORDER);
            System.assertNotEquals(null,result,'Passed');
        }catch(Exception e){
            System.assertEquals('Invalid Country/Postal Code',e.getMessage(),'Passed');
        }
        Test.stopTest();

    }

    @isTest
    static void testCalculateTaxesException2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(300)); 

        String cartId = [SELECT Id FROM WebCart WHERE Name =: 'Cart'].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;

        CartExtension.Cart cart = CartExtension.CartTestUtil.getCart(cartId);
        CartExtension.CartCalculateCalculatorRequest request = new CartExtension.CartCalculateCalculatorRequest(cart, CartExtension.OptionalBuyerActionDetails.empty());
        Test.startTest();

         try{
            Map<String,B2BAvalaraTaxModel> result  = B2BAvalaraTaxUtil.calculateTaxes(cart, cartId, accountId,'USD', SIB_Constants.TAX_TYPE_SALESORDER);
            System.assertNotEquals(null,result,'Passed');
        }catch(Exception e){
            System.assertEquals('Tax Service Error',e.getMessage(),'Passed');
        }
        Test.stopTest();

    }

    
    @isTest
    static void calculateTax() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201)); 
        Id cartId = [SELECT Id FROM WebCart LIMIT 1].Id;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        Map<String,B2BAvalaraTaxModel> result = B2BAvalaraTaxUtil.calculateTax(cartId, cartId, accountId,'USD', SIB_Constants.TAX_TYPE_SALESORDER);
        System.assertNotEquals(null,result,'Passed');
        Test.stopTest();
    }

    @isTest
    static void calculateTaxException() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400));
        Id cartId = [SELECT Id FROM WebCart LIMIT 1].Id;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        try{
            Map<String,B2BAvalaraTaxModel> result = B2BAvalaraTaxUtil.calculateTax(cartId, cartId, accountId,'USD', SIB_Constants.TAX_TYPE_SALESORDER);
            System.assertNotEquals(null,result,'Passed');
        }catch(Exception e){
            System.assertEquals('Invalid Country/Postal Code',e.getMessage(),'Passed');
        }
        Test.stopTest();
    }

    @isTest
    static void calculateTaxException2() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(300));
        Id cartId = [SELECT Id FROM WebCart LIMIT 1].Id;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        try{
            Map<String,B2BAvalaraTaxModel> result = B2BAvalaraTaxUtil.calculateTax(cartId, cartId, accountId,'USD', SIB_Constants.TAX_TYPE_SALESORDER);
            System.assertNotEquals(null,result,'Passed');
        }catch(Exception e){
            System.assertEquals('Tax Service Error',e.getMessage(),'Passed');
        }
        Test.stopTest();
    }


   
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer statusCode;

        public MockHttpResponseGenerator(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"totalTaxable":10.0,"rate":2.0,"totalTax":2.0,"country":"US","lines":[{"id":1006064637940,"itemCode":"TestSKU","taxCalculated":"8.0","country":"IO","taxAmount":0.0,"taxRate":0.0,"taxableAmount":0.0,"totalAmount":0.0,"details":[{"id":5006071753611,"rate":0.000000}]}]}');
            res.setStatusCode(statusCode);
            return res;
        }
    }
}