@IsTest
private with sharing class B2BAvaTaxTest {
    @testSetup 
    static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;

        ContactPointAddress cpa1 = new ContactPointAddress(Name='CPA1', Street='Street1', City='Mojave', StateCode='CA',
               CountryCode='US', PostalCode='90251', IsDefault=true, AddressType='Billing', ParentId=testAccount.Id);
        insert cpa1;

        WebStore webStore = new WebStore(Name = 'TestWebStore', 
                                        DefaultLanguage = 'en_US');
        insert webStore;

        WebCart webCart = new WebCart(Name = 'Cart', 
                           WebStoreId = webStore.Id,
                           AccountId = testAccount.Id,
                           BillingStreet = 'Street1',
                           BillingCity = 'Mojave',
                           BillingState = 'CA',
                           BillingCountry = 'US',
                           BillingPostalCode = '90251');
        insert webCart;

        CartDeliveryGroup testCartDeliveryGroup = new CartDeliveryGroup(Name = 'Default Delivery', CartId = webCart.id);
        insert testCartDeliveryGroup;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', 
                            Seats_Available__c = 10,
                            Training_Location_Street__c = 'Street1',
                            Training_Location_City__c = 'Mojave',
                            Training_Location_State__c = 'CA',
                            Training_Location_Country__c = 'United States',
                            Training_Location_Zip_Code__c = '90251');
        insert testCampaign;

        Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
        insert testSession;

        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'TestSKU', 
            Description = 'Test Description',
            Product_Group__c = 'Public Course',
            TTS_Event__c = testCampaign.Id
        );

        CartItem cartItem = new CartItem(
            CartId = webCart.id, 
            Sku = 'TestSKU',
            Quantity = 3.0,
            Type = 'Product', 
            Name = 'TestProduct', 
            CurrencyIsoCode = 'USD',
            Product2Id = product.id,
            CartDeliveryGroupId = testCartDeliveryGroup.Id);
        insert cartItem;
    }

    @IsTest
    static void testCalculateTax(){
        WebCart webCart = [SELECT Id, Status FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartitem = [
            SELECT Id, Sku, TotalPriceAfterAllAdjustments, Cart.Account.Name, Quantity, Product2.Delivery_Format__c, 
                Product2.Product_Group__c, Product2.In_Person_Tax_Code__c, 
                Product2.Virtual_Tax_Code__c, Product2.Training_Location_Country_formula__c, 
                Product2.Training_Location_Zip_Code_formula__c, Cart.BillingCountry, 
                Cart.BillingPostalCode 
            FROM CartItem WHERE CartId =: webCart.id LIMIT 1];

        B2BAvaTax b2bAvaTaxInstance = new B2BAvaTax();

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();

        sfdc_checkout.IntegrationStatus status = b2bAvaTaxInstance.startCartProcessAsync(jobInfo, webCart.Id);
    }

    @IsTest
    static void testCalculateTaxException(){
        WebCart webCart = [SELECT Id, Status FROM WebCart WHERE Name = 'Cart' LIMIT 1];

        CartItem cartitem = [
            SELECT Id, Sku, TotalPriceAfterAllAdjustments, Quantity, Product2.Delivery_Format__c, 
                Product2.Product_Group__c, Product2.In_Person_Tax_Code__c, 
                Product2.Virtual_Tax_Code__c, Product2.Training_Location_Country_formula__c, 
                Product2.Training_Location_Zip_Code_formula__c, Cart.BillingCountry, 
                Cart.BillingPostalCode 
            FROM CartItem WHERE CartId =: webCart.id LIMIT 1];

        if(cartitem != null)
        {
            cartitem.Sku = 'TestSKU1';
            update cartitem;
        }

        B2BAvaTax b2bAvaTaxInstance = new B2BAvaTax();

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();

        sfdc_checkout.IntegrationStatus status = b2bAvaTaxInstance.startCartProcessAsync(jobInfo, webCart.Id);
    }
}