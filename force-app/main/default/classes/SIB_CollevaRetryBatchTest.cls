@isTest
public class SIB_CollevaRetryBatchTest {
    public SIB_CollevaRetryBatchTest() {

    }
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
     
        
    @isTest(SeeAllData = true)
    static void retryCollevaBatchTest(){
        setup();
        Order o = [SELECT Id,OrderNumber FROM Order WHERE Name='Order 1001' LIMIT 1];        
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE OriginalOrderId=:o.Id LIMIT 1];
        os.Colleva_Order__c = true;
        update os;
        List<String> osIds =  new List<String>{os.Id};



        Test.startTest();
            SIB_CollevaRetryBatch retryCollevaBatch = new SIB_CollevaRetryBatch();
            Database.executeBatch(retryCollevaBatch);
            SIB_CollevaRetrySchedule sc = new SIB_CollevaRetrySchedule();
            sc.execute(null);
            SIB_CollevaContactUpdate.updateCollevaIdOnContact(osIds);
        Test.stopTest();
    }


    @isTest(seeAllData=true)
    static void updateCollevaIdOnContactTest(){

        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalType = 'None' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
        
        // Create a test user and account
        setup();
        Account acc = [select id,name from account where name ='Test Account' LIMIT 1];
        Contact contact = new Contact(AccountId=acc.Id, LastName='TestContact',Colleva_Id__c =0);
        insert contact;

        // get System Admin profile
        Profile customerCommunityProfile = [SELECT Id FROM Profile WHERE Name = 'B2B Customer Community Plus User' LIMIT 1];

        // generate unique username string for User record
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@test.com';
    
        User user = new User(ContactId=contact.Id, ProfileId=customerCommunityProfile.Id, Alias='testuser', Email='testuser@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName, CollevaAccess__c=true);
        insert user;

        // insert buyer account
        BuyerAccount buyerAccount = new BuyerAccount(Name='Test Buyer Account', BuyerId=acc.Id, CurrencyIsoCode='USD');
        insert buyerAccount;
        
        Order o = [SELECT Id,OrderNumber FROM Order WHERE Name='Order 1001' LIMIT 1];        
        OrderSummary os = [SELECT Id,accountId FROM OrderSummary WHERE OriginalOrderId=:o.Id LIMIT 1];
        os.Colleva_Order__c = true;
        update os;
        System.debug('os : '+ os);
        System.debug('user : '+ user);
        List<String> osIds = new List<String>{os.Id};
        Test.startTest();
            SIB_CollevaContactUpdate.updateCollevaIdOnContact(osIds);
            SIB_CollevaContactUpdate.tst();
        Test.stopTest();
        }


        
    }

}