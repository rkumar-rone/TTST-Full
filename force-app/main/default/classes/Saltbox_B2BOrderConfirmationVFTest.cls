/**
 * @description: test class for Saltbox_B2BOrderConfirmationVFController
 * @author: Mohammmed Jukker
 * @last modified date: 11-30-2023
 * @last modified by: Rodrigo Hernandez
 */
@isTest(SeeAllData=true)
public class Saltbox_B2BOrderConfirmationVFTest {
    @isTest
    private static void testGetOrderSummary() {
        //Given
        //Saltbox_B2BOrderConfirmationVFController controller = createTestSetup();
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
        OrderSummary orderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS' LIMIT 1];
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = orderSummary.Id;
        controller.recipientName = 'Test Contact';

        //When
        OrderSummary summary = controller.getOrderSummary();
        
        //Then
        System.assertEquals(controller.orderSummaryId, summary.Id);
    }
    
    @isTest
    private static void testGetOrderSummary_WhenOrderSummaryBlank() {
        //When
        OrderSummary summary = new Saltbox_B2BOrderConfirmationVFController().getOrderSummary();
        
        //Then
        System.assertEquals(null, summary.Id);
    }

    @isTest
    private static void testGetShippingAddress() {
        //Given
        //Saltbox_B2BOrderConfirmationVFController controller = createTestSetup();
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
        OrderSummary orderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS' LIMIT 1];
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = orderSummary.Id;
        controller.recipientName = 'Test Contact';

        //When
        OrderDeliveryGroupSummary summaryGroup = controller.getShippingAddress();
        
        //Then
        OrderDeliveryGroupSummary retrievedSummaryGroup = [SELECT Id FROM OrderDeliveryGroupSummary WHERE OrderSummaryId = :orderSummary.Id LIMIT 1];
        System.assertEquals(retrievedSummaryGroup.Id, summaryGroup.Id);
    }

    @isTest
    private static void testGetShippingAddress_WhenOrderSummaryBlank() {
        //When
        OrderDeliveryGroupSummary summaryGroup = new Saltbox_B2BOrderConfirmationVFController().getShippingAddress();
        
        //Then
        System.assertEquals(null, summaryGroup.Id);
    }

    @isTest
    private static void testGetOrderItems() {
        //Given
        //Saltbox_B2BOrderConfirmationVFController controller = createTestSetup();
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
        OrderSummary orderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS' LIMIT 1];
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = orderSummary.Id;
        controller.recipientName = 'Test Contact';

        //When
        List<Saltbox_B2BOrderConfirmationVFController.OrderItem> orderItems = controller.getOrderItems();
        
        //Then
        System.assert(!orderItems.isEmpty());
    }

    @isTest
    private static void testGetOrderItems_WhenOrderSummaryBlank() {
        //When
        List<Saltbox_B2BOrderConfirmationVFController.OrderItem> orderItems = new Saltbox_B2BOrderConfirmationVFController().getOrderItems();
        
        //Then
        System.assert(orderItems.isEmpty());
    }
    
    @isTest
    private static void testGetSiteURL() {
        //Given
        //Saltbox_B2BOrderConfirmationVFController controller = createTestSetup();
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
        OrderSummary orderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS' LIMIT 1];
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = orderSummary.Id;
        controller.recipientName = 'Test Contact';

        //When
        String siteURL = controller.getSiteURL();
        
        //Then
        System.assert(siteURL.contains('/s/OrderSummary/' + controller.orderSummaryId), siteURL);
    }
    
    @isTest
    private static void testGetSiteURL_WhenOrderSummaryBlank() {
        //When
        String siteURL = new Saltbox_B2BOrderConfirmationVFController().getSiteURL();
        
        //Then
        System.assertEquals(null, siteURL);
    }

    @isTest
    static void testGetCurrencySymbol(){
        Saltbox_TestDataFactory.buildManagedOrderSummary('TestOS');
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS' LIMIT 1];
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = os.Id;
        controller.recipientName = 'Test Contact';

        Test.startTest();
        String currencySymbol = controller.getCurrencySymbol();
        Test.stopTest();

        System.assertEquals('$', currencySymbol);
    }

    @isTest
    static void testGetCurrencySymbol_WhenOrderSummaryBlank(){
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();

        Test.startTest();
        String currencySymbol = controller.getCurrencySymbol();
        Test.stopTest();

        System.assertEquals(null, currencySymbol);
    }

    /* @isTest
    private static void testGetMaskedCCNumber() {
        //Given
        //Saltbox_B2BOrderConfirmationVFController controller = createTestSetup();
        B2B_Payment_Authorization__c auth = [SELECT Id, Masked_Card_Number__c, Order_Summary__c FROM B2B_Payment_Authorization__c WHERE Order_Summary__c != :null LIMIT 1];
        //OrderSummary orderSummary = [SELECT Id FROM OrderSummary LIMIT 1];
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = auth.Order_Summary__c;
        controller.recipientName = 'Test Contact';

        //When
        String maskedCC = controller.getMaskedCCNumber();
        
        //Then
        System.assertEquals(auth.Masked_Card_Number__c, maskedCC);
    }

    @isTest
    private static void testGetMaskedCCNumber_WhenOrderSummaryBlank() {
        //When
        String maskedCC = new Saltbox_B2BOrderConfirmationVFController().getMaskedCCNumber();
        
        //Then
        System.assertEquals(null, maskedCC);
    }

    @isTest
    private static void testGetMaskedCCNumber_WhenPaymentAuthorizationDontExistForOrderSummaryId() {
        //Given
        //Saltbox_B2BOrderConfirmationVFController controller = createTestSetup();
        B2B_Payment_Authorization__c auth = [SELECT Id, Masked_Card_Number__c, Order_Summary__c FROM B2B_Payment_Authorization__c WHERE Order_Summary__c != :null LIMIT 1];
        //OrderSummary orderSummary = [SELECT Id FROM OrderSummary LIMIT 1];
        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = '1234567890ABCDEF';
        controller.recipientName = 'Test Contact';

        //When
        String maskedCC = controller.getMaskedCCNumber();
        
        //Then
        System.assertEquals(null, maskedCC);
    } */

    private static Saltbox_B2BOrderConfirmationVFController createTestSetup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert contact;

        WebStore store = new WebStore(Name = 'Test Store');
        insert store;

        WebCart cart = new WebCart(Name = 'Test Cart', AccountId = acc.Id, WebStoreId = STORE.Id);
        insert cart;

        Product2 prod = new Product2(Name = 'Test Product 1', StockKeepingUnit = 'Test-product-SKU-11');
        insert prod;

        CartDeliveryGroup cdg = new CartDeliveryGroup(Name = 'Test CDG', CartId = cart.Id);
        insert cdg;

        CartItem cItem = new CartItem(Name = 'Test Cart Item', CartDeliveryGroupId = cdg.Id, CartId = cart.Id, Product2Id = prod.Id, Quantity = 2, Sku = 'Test-product-SKU-11', TotalPriceAfterAllAdjustments = 20.0);
        insert cItem; 

        OrderSummary orderSummary = new OrderSummary();
        orderSummary.OrderedDate = System.today();
        orderSummary.OrderNumber = '00000123';
        orderSummary.PoNumber = 'TestPO123';
        orderSummary.BillingState = 'Test State';
        orderSummary.BillingStreet = 'Test Street';
        orderSummary.BillingPostalCode = '123456';
        orderSummary.BillingCity = 'Test City';
        orderSummary.BillingCountry = 'Test Country';
        insert orderSummary;

        OrderDeliveryGroupSummary odgs = new OrderDeliveryGroupSummary();
        odgs.OrderSummaryId = orderSummary.Id;
        odgs.DeliverToName = 'Test Name';
        odgs.DeliverToCity = 'Test City';
        odgs.DeliverToCountry = 'Test Country';
        odgs.DeliverToPostalCode = '123456';
        odgs.DeliverToState = 'Test State';
        odgs.DeliverToStreet = 'Test Street';
        insert odgs;

        Saltbox_B2BOrderConfirmationVFController controller = new Saltbox_B2BOrderConfirmationVFController();
        controller.orderSummaryId = orderSummary.Id;
        controller.recipientName = 'Test Contact';

        return controller;
    }
}