@IsTest
private class B2BAvalaraTaxCalloutTest {

    @isTest(seeAllData=true)
    static void makeCalloutTest(){

        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;

        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert contact;

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
        insert product;

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

        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = :B2BGetInfo.TTS_PRICEBOOK LIMIT 1];

        Id standardPriceBookId = Test.getStandardPricebookId();

        // Create a standard price for the product
        PricebookEntry standardPbe = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, Product2Id = product.Id,
            UnitPrice = 100.00, IsActive = true);
        insert standardPbe;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;

        Order order = new Order(
            EffectiveDate = Date.today(),
            Status = 'Draft',
            AccountId = testAccount.id,
            BillToContactId = contact.id,
            BillingCountry = 'US',
            Name = 'Test Order',
            Pricebook2Id  = pricebook.Id
        );
        insert order;

        OrderDeliveryMethod odm = new OrderDeliveryMethod(
            Name = 'Test Delivery Method',
            IsActive = true, 
            Carrier = 'USPS'
        );
        insert odm;

        OrderDeliveryGroup odg = new OrderDeliveryGroup(
            DeliverToName = 'Test Delivery Group',
            OrderId = order.Id,
            DeliverToCountry = 'US',
            OrderDeliveryMethodId = odm.Id
        );
        insert odg;

        OrderItem orderItem = new OrderItem(
            Product2Id = product.Id,
            Type = 'Order Product',
            Quantity = 1,
            ListPrice = 1000,
            UnitPrice = 1000,
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            OrderDeliveryGroupId = odg.Id,
            TotalLineAmount = 1
        );
        insert orderItem;

        order.Status='Activated';
        update order;

        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId = order.Id;
        osir.orderLifeCycleType = 'UNMANAGED';
        ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        
        OrderSummary os = [SELECT Id,OrderedDate,Status, CartId__c, Payment_Method__c FROM OrderSummary WHERE OriginalOrderId=:order.Id LIMIT 1];
        os.CartId__c = webCart.Id;
        os.Payment_Method__c = 'Credit Card';
        os.Status = 'Completed';

        update os;

        List<Id> ids = new List<Id>();
        ids.add(os.Id);

        B2BAvalaraTaxCallout.makeCallout(ids);
    }
}