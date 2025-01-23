@isTest
private class B2BDeliverySampleTest {
    @testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;

        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;

        Product2 odmProd = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'Test Product',
            Description = 'Test Product',
            Unit_Cost__c = 1
        );
        insert odmProd;

        OrderDeliveryMethod odm = new OrderDeliveryMethod(
            Name = 'Test ODM',
            IsActive = true, 
            Carrier = 'Domestic',
            ClassOfService = 'Ground',
            ProductId = odmProd.Id
          );
          insert odm;

          OrderDeliveryMethod odm2 = new OrderDeliveryMethod(
            Name = 'International',
            IsActive = true, 
            Carrier = 'International',
            ClassOfService = 'Ground',
            ProductId = odmProd.Id
          );
          insert odm2;

          OrderDeliveryMethod odm3 = new OrderDeliveryMethod(
            Name = 'Domestic',
            IsActive = true, 
            Carrier = 'Domestic',
            ClassOfService = 'Ground',
            ProductId = odmProd.Id
          );
          insert odm3;
    }
    

    @isTest static void testIntegrationRunsSuccessfully() {
        Test.startTest();
        // Associate the callout with a mock response.
        
        // Test: execute the integration for the test cart ID.
        B2BDeliverySample apexSample = new B2BDeliverySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        // Verify: the integration executed successfully
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }

    @isTest static void testShippingOptions(){
        B2BDeliverySample.ShippingOptionsAndRatesFromExternalService providers = new B2BDeliverySample.ShippingOptionsAndRatesFromExternalService('Test Name', 'Test Provider', 1, 2, 'Service');
        String provider = '';
        String name = '';
        Decimal rate = 0;
        Decimal otherCost = 0;
        String service = '';

        Test.startTest();
        provider = providers.getProvider();
        name = providers.getName();
        rate = providers.getRate();
        otherCost = providers.getOtherCost();
        service = providers.getServiceName();
        Test.stopTest();

        System.assertEquals('Test Provider', provider);
        System.assertEquals('Test Name', name);
        System.assertEquals(1, rate);
        System.assertEquals(2, otherCost);
        System.assertEquals('Service', service);
    }
    
    @isTest static void testPopulateCartDeliveryGroupMethodWithShippingOptions(){
        B2BDeliverySample.ShippingOptionsAndRatesFromExternalService providers = new B2BDeliverySample.ShippingOptionsAndRatesFromExternalService('Test Name', 'Test Provider', 1, 2, 'Service');
        Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE Name='Default Delivery 1' LIMIT 1].Id;
        Id deliveryMethodId = [SELECT Id FROM OrderDeliveryMethod WHERE Name='Test ODM' LIMIT 1].Id;
        Id webCartId = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1].Id;

        Test.startTest();
        B2BDeliverySample.populateCartDeliveryGroupMethodWithShippingOptions(providers, cartDeliveryGroupId, deliveryMethodId, webCartId);
        Test.stopTest();

        cartDeliveryGroupMethod cdgm = [SELECT Id FROM cartDeliveryGroupMethod WHERE CartDeliveryGroupId=:cartDeliveryGroupId LIMIT 1];
        System.assert(cdgm != null);
    }

    @isTest static void testIntegrationStatusFailedWithCartValidationOutputError(){
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        integStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        String errorMessage = 'Test Error Message';
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        Id cartId = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1].Id;

        Test.startTest();
        B2BDeliverySample.integrationStatusFailedWithCartValidationOutputError(integStatus, errorMessage, integInfo, cartId);
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integStatus.status);
    }

    @isTest static void testGetShippingChargeProduct2Id(){
        OrderDeliveryMethod odm = [SELECT Id FROM OrderDeliveryMethod WHERE Name='Test ODM' LIMIT 1];
        Id shippingChargeProduct2Id = B2BDeliverySample.getShippingChargeProduct2Id(odm.id);
        Product2 shippingChargeProduct2 = [SELECT Id FROM Product2 WHERE Name='Test Product' LIMIT 1];
        System.assertEquals(shippingChargeProduct2.Id, shippingChargeProduct2Id);
    }

    @isTest static void testGetOrderDeliveryMethods(){
        B2BDeliverySample.ShippingOptionsAndRatesFromExternalService providers = new B2BDeliverySample.ShippingOptionsAndRatesFromExternalService('Test Name', 'Test Provider', 1, 2, 'Service');
        B2BDeliverySample.ShippingOptionsAndRatesFromExternalService providers2 = new B2BDeliverySample.ShippingOptionsAndRatesFromExternalService('Test Name', 'Test Provider', 1, 2, 'Service');
        List<B2BDeliverySample.ShippingOptionsAndRatesFromExternalService> providersList = new List<B2BDeliverySample.ShippingOptionsAndRatesFromExternalService>();
        providersList.add(providers);
        providersList.add(providers2);

        Test.startTest();
        List<Id> odmList = B2BDeliverySample.getOrderDeliveryMethods(providersList);
        Test.stopTest();

        System.assertEquals(2, odmList.size());
    }

    @isTest static void testGetDefaultShippingChargeProduct2Id(){
        Product2 shippingChargeProduct2 = new Product2(
            Name = 'Shipping Charge for this delivery method',
            IsActive = true,
            ProductCode = 'Test Product',
            Description = 'Test Product',
            Unit_Cost__c = 1
        );
        insert shippingChargeProduct2;
        Test.startTest();
        Id shippingChargeProduct2Id = B2BDeliverySample.getDefaultShippingChargeProduct2Id();
        Test.stopTest();

        System.assertEquals(shippingChargeProduct2.Id, shippingChargeProduct2Id);
    }

    @isTest static void testGetDefaultShippingChargeProduct2IdWithNoProduct(){
        Test.startTest();
        Id shippingChargeProduct2Id = B2BDeliverySample.getDefaultShippingChargeProduct2Id();
        Test.stopTest();

        Id prodId = [SELECT Id FROM Product2 WHERE Name='Shipping Charge for this delivery method' LIMIT 1].Id;

        System.assertEquals(prodId, shippingChargeProduct2Id);
    }

    @isTest static void testGetShippingOptionsAndRatesFromExternalService(){
        Test.startTest();
        List<B2BDeliverySample.ShippingOptionsAndRatesFromExternalService> providersList = B2BDeliverySample.getShippingOptionsAndRatesFromExternalService(2);
        Test.stopTest();

        System.assertEquals(2, providersList.size());
    }
}