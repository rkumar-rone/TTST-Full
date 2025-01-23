/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_OrderServiceTest {
    //To create order summary in test class, we need to use connect api which enforces the use of SeeAllData=true
	@IsTest(SeeAllData=true)
    static void setup(){
    	Pricebook2 priceBook = new Pricebook2();
        priceBook.Name = 'Test Price Book';
        insert priceBook;
 
        Product2 product2 = new Product2(
            Name = 'Product Name',
            IsActive = true
        );
        insert product2;
        
        PricebookEntry pbStd = new PricebookEntry(
        	Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbStd;
 
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = priceBook.Id,
            Product2Id = product2.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbEntry;
 
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
 
        Order order  = new Order(
            Status = 'Draft',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Pricebook2Id = priceBook.Id,
            Name = 'Order 1001'
        );
        insert order;
 
        OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(
            Name = 'OrderDeliveryMethod Name'
        );
        insert orderDeliveryMethod;
 
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            DeliverToName = 'orderDeliveryGroup Name',
            OrderDeliveryMethodId = orderDeliveryMethod.Id,
            OrderId = order.Id
        );
        insert orderDeliveryGroup;
 
        OrderItem orderItem = new OrderItem(
            PricebookEntryId = pbEntry.Id,
            OrderId = order.Id,
            Quantity = 5,
            UnitPrice = 150,
            OrderDeliveryGroupId = orderDeliveryGroup.Id,
            TotalLineAmount = 250
        );
        insert orderItem;
 
        order.Status = 'Activated';
        update order;
 
        ConnectApi.OrderSummaryInputRepresentation inputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        inputRepresentation.orderId = order.Id;
        ConnectApi.OrderSummaryOutputRepresentation outputRepresentation = ConnectApi.OrderSummaryCreation.createOrderSummary(inputRepresentation);
    }
    
    @isTest
    static void getOrderConfigurationTest(){
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        config.ConfigJSON__c = '{"id":"000000000000000AAA"}';
        insert config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('configurationType','ORDER DETAILS');
        Test.startTest();
        mapParams = SIB_OrderService.getOrderConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get('isSuccess'),'getOrderConfigurationTest assertion failed');
    }
    
    @isTest
    static void getOrderConfigurationExceptionTest(){
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('configurationType','ORDER DETAILS');
        Test.startTest();
        mapParams = SIB_OrderService.getOrderConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get('isSuccess'),'getOrderConfigurationExceptionTest assertion failed');
    }
    
    @isTest(SeeAllData = true)
    static void getOrderDetailsOS1Test(){
        setup();
        Order o = [SELECT Id,OrderNumber FROM Order WHERE Name='Order 1001' LIMIT 1];
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE OriginalOrderId=:o.Id LIMIT 1];
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        config.ConfigJSON__c = '{"objectApiName":"OrderSummary"}';
        insert config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('recordId',os.Id);
        Test.startTest();
        mapParams = SIB_OrderService.getOrderDetails(mapParams);
        Test.stopTest();   
    }
    
    @isTest(SeeAllData = true)
    static void getOrderDetailsOS2Test(){
        setup();
        Order o = [SELECT Id,OrderNumber FROM Order WHERE Name='Order 1001' LIMIT 1];
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE OriginalOrderId=:o.Id LIMIT 1];
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        config.ConfigJSON__c = '{"objectApiName":"OrderSummary"}';
        insert config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('orderNumber',o.OrderNumber);
        Test.startTest();
        mapParams = SIB_OrderService.getOrderDetails(mapParams);
        Test.stopTest();  
    }
    
    @isTest
    static void getOrderDetailsOS3Test(){
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        config.ConfigJSON__c = '{"objectApiName":"OrderSummary"}';
        insert config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('orderNumber','invalid35505');
        Test.startTest();
        mapParams = SIB_OrderService.getOrderDetails(mapParams);
        Test.stopTest();  

    }
    
    @isTest(SeeAllData = true)
    static void getOrderDetailsO1Test(){
        setup();
        Order o = [SELECT Id,OrderNumber FROM Order WHERE Name='Order 1001' LIMIT 1];
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE OriginalOrderId=:o.Id LIMIT 1];
        List<SIB_StorefrontConfiguration__c> existingconfigs = [SELECT Id FROM SIB_StorefrontConfiguration__c WHERE ConfigurationType__c='ORDER DETAILS'];
        if(!existingconfigs.isEmpty()){
            delete existingconfigs;
        }
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        config.ConfigJSON__c = '{"objectApiName":"Order"}';
        insert config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('recordId',o.Id);
        Test.startTest();
        mapParams = SIB_OrderService.getOrderDetails(mapParams);
        Test.stopTest(); 
    }
    
    @isTest(SeeAllData = true)
    static void getOrderDetailsO2Test(){
        setup();
        Order o = [SELECT Id,OrderNumber FROM Order WHERE Name='Order 1001' LIMIT 1];
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE OriginalOrderId=:o.Id LIMIT 1];
        List<SIB_StorefrontConfiguration__c> existingconfigs = [SELECT Id FROM SIB_StorefrontConfiguration__c WHERE ConfigurationType__c='ORDER DETAILS'];
        if(!existingconfigs.isEmpty()){
            delete existingconfigs;
        }
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        config.ConfigJSON__c = '{"objectApiName":"Order"}';
        insert config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('orderNumber',o.OrderNumber);
        Test.startTest();
        mapParams = SIB_OrderService.getOrderDetails(mapParams);
        Test.stopTest(); 
    }
    
    @isTest
    static void getOrderDetailsO3Test(){
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        List<SIB_StorefrontConfiguration__c> existingconfigs = [SELECT Id FROM SIB_StorefrontConfiguration__c WHERE ConfigurationType__c='ORDER DETAILS'];
        if(!existingconfigs.isEmpty()){
            delete existingconfigs;
        }
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        config.ConfigJSON__c = '{"objectApiName":"Order"}';
        insert config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('orderNumber','invalid35505');
        Test.startTest();
        mapParams = SIB_OrderService.getOrderDetails(mapParams);
        Test.stopTest(); 
    }
}