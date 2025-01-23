/**
 * @description       : Test class for SIB_TaxCartCalculatorExtension
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_TaxCartCalculatorExtensionTest {
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
    static void testCalculate(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201)); 

        Id cartId = [SELECT Id FROM WebCart WHERE Name =: 'Cart'].Id;
        CartExtension.Cart cart = CartExtension.CartTestUtil.getCart(cartId);
        CartExtension.CartCalculateCalculatorRequest request = new CartExtension.CartCalculateCalculatorRequest(cart, CartExtension.OptionalBuyerActionDetails.empty());
        SIB_TaxCartCalculatorExtension calculator = new SIB_TaxCartCalculatorExtension();
        Test.startTest();
        calculator.calculate(request);
        calculator.setErrorInCart(cart,'Test Error Message');
        Test.stopTest();

    }

    @isTest
    static void testCalculateException(){
        Id userId = [SELECT Id FROM User WHERE Lastname = 'Testing' LIMIT 1].Id;
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact customerContact = [SELECT Id,AccountId FROM Contact WHERE AccountId = :account.Id LIMIT 1];
    
        WebCart cart = new  WebCart();
        cart.CurrencyISOCode = 'USD';
        cart.Name = 'Cart';
        cart.Status = 'Closed';
        cart.WebStoreId = webStore.Id;
        cart.AccountId = customerContact.AccountId;
        cart.OwnerId = userId;
        cart.BillingCity = 'Los Angeles';
        cart.BillingCountryCode = 'US';
        cart.BillingStateCode = 'CA';
        cart.BillingPostalCode = '75040';
        cart.BillingStreet = '123 Adven Street';
        insert cart;
    
    
        CartExtension.Cart carts = CartExtension.CartTestUtil.getCart(cart.Id);
        CartExtension.CartCalculateCalculatorRequest request = new CartExtension.CartCalculateCalculatorRequest(carts, CartExtension.OptionalBuyerActionDetails.empty());
        SIB_TaxCartCalculatorExtension calculator = new SIB_TaxCartCalculatorExtension();
        Test.startTest();
        calculator.calculate(request);
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