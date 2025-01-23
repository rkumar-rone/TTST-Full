/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class B2BGetInfoTest {

    @isTest(SeeAllData=true)
    static void testGetProduct_Success() {

        Account account = new Account(Name='TestAccount');
        insert account;
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description'
        );

        insert product;
        
        String networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStore.Name = 'TTS B2B Store' LIMIT 1].NetworkId;

        // Call the method to test
        Test.startTest();
        ConnectApi.ProductDetail result = B2BGetInfo.getProduct(networkId, product.Id, null);
        Test.stopTest();

    }

    @IsTest
    static void testCheckProductIsInStock(){
        
        Assert.areEqual(true, B2BGetInfo.checkProductIsInStock(null));
    }

    @IsTest(SeeAllData=true)
    static void testGetCartSummary(){

        Account account = new Account(Name='TestAccount');
        insert account;
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description'
        );

        insert product;
        
        String networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStore.Name = 'TTS B2B Store' LIMIT 1].NetworkId;
        
        Test.startTest();
        ConnectApi.CartSummary result = B2BGetInfo.getCartSummary(networkId, null, 'USD');
        Test.stopTest();
        
    }

    @IsTest(SeeAllData=true)
    static void testAddToCart(){
        
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Seats_Available__c = 10);
        insert testCampaign;

        Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
        insert testSession;

        // Pricebook2 standardPricebook = new Pricebook2(
        //     Id = Test.getStandardPricebookId(),
        //     IsActive = true
        // );

        // update standardPricebook;

        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = :B2BGetInfo.TTS_PRICEBOOK LIMIT 1];
        
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description',
            TTS_Event__c = testCampaign.Id
        );
        insert product;

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

        TTSB2BCheckInventoryTest.insertCartItem(cart.Id, cartDeliveryGroup.Id, product.Id);

        String networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStore.Name = 'TTS B2B Store' LIMIT 1].NetworkId;
        
        Test.startTest();
        ConnectApi.CartItem cartItem = B2BGetInfo.addToCart(networkId, product.Id, '1', null, cart.Id, 'testSelectedSession: session', 1, 'USD');
        Test.stopTest();
        
    }

    @IsTest(SeeAllData=true)
    static void testCreateAndAddToList(){

        Account account = new Account(Name='TestAccount');
        insert account;
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description'
        );

        insert product;
        
        String networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStore.Name = 'TTS B2B Store' LIMIT 1].NetworkId;
        
        Test.startTest();
        ConnectApi.Wishlist result = B2BGetInfo.createAndAddToList(networkId, product.Id, 'testWishlist', null);
        Test.stopTest();
        
    }

    @IsTest(SeeAllData=true)
    static void testGetSessions(){
        Account account = new Account(Name='TestAccount');
        insert account;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Seats_Available__c = 10);
        insert testCampaign;

        Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
        insert testSession;
        
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description',
            TTS_Event__c = testCampaign.Id
        );

        insert product;

        Test.startTest();
        List<Session__c> lstSessions = B2BGetInfo.getSessions(product.Id);
        Test.stopTest();

        Assert.areEqual(1, lstSessions.size());
        Assert.areEqual('Test Session', lstSessions.get(0).Name);
        
    }

    @IsTest
    static void testCreateGroupRecipients(){
        
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Seats_Available__c = 10);
        insert testCampaign;

        Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
        insert testSession;

        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description',
            TTS_Event__c = testCampaign.Id
        );
        insert product;

        TTSB2BCheckInventoryTest.insertCartItem(cart.Id, cartDeliveryGroup.Id, product.Id);

        Test.startTest();
        B2BGetInfo.createGroupRecepients(
            new List<Group_Recepient__c>{
                new Group_Recepient__c(Recepient_Email__c='test@test.com', Cart__c = cart.Id)
            }, 
            true, 
            cart.Id
        );

        List<Group_Recepient__c> lstGroupRecipients = [SELECT Id FROM Group_Recepient__c WHERE Cart__c = :cart.Id];

        Assert.areEqual(3, lstGroupRecipients.size());

        B2BGetInfo.deleteRecipientsFromCheckout(cart.Id);
        Test.stopTest();

        Assert.areEqual(0, [SELECT count() FROM Group_Recepient__c WHERE Cart__c = :cart.Id]);

    }

    @IsTest
    static void testGetCartItems(){
        
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description'
        );
        insert product;

        TTSB2BCheckInventoryTest.insertCartItem(cart.Id, cartDeliveryGroup.Id, product.Id);

        Test.startTest();
        List<CartItem> cartItems = B2BGetInfo.getCartItems(cart.Id);
        Integer numOfRecipients = B2BGetInfo.getRecipientsForCart(cart.Id);
        Test.stopTest();

        Assert.areEqual(1, cartItems.size());
        Assert.areEqual(0, numOfRecipients);
    }

    @IsTest
    static void testGetCartByUser(){
        
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id, Status='Active');
        insert cart;

        Test.startTest();
        String cartJson = B2BGetInfo.getCartByUser(UserInfo.getUserId());
        Test.stopTest();

        Assert.isNotNull(cartJson, 'Cart should not be null');
    }

    @IsTest(SeeAllData=true)
    static void testCreateCart(){
        Account account = new Account(Name='TestAccount');
        insert account;

        Test.startTest();
        String cartJson = B2BGetInfo.createCart('USD', UserInfo.getUserId(), account.Id);
        Test.stopTest();
        
        Assert.isNotNull(cartJson, 'Cart should not be null');
    }

    @IsTest(SeeAllData=true)
    static void testDeleteCart(){

        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id, Status='Active');
        insert cart;

        Test.startTest();
        String result = B2BGetInfo.deleteCart(cart.Id);
        Test.stopTest();
     
        Assert.areEqual('success', result);
    }

    @IsTest(SeeAllData=true)
    static void testGetProductPrice(){

        Account account = new Account(Name='TestAccount');
        insert account;
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description'
        );

        insert product;
        
        String networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStore.Name = 'TTS B2B Store' LIMIT 1].NetworkId;
        
        Test.startTest();
        ConnectApi.ProductPrice result = B2BGetInfo.getProductPrice(networkId, product.Id, null);
        Test.stopTest();
        
    }

    @isTest
    static void saveOneSelectionTest(){
        List<Session__c> sessionsList = [SELECT Event__c,Id,Name,Waiting_List_Members__c FROM Session__c WHERE Waiting_List_Members__c > 0 ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];

        List<String> eventIds = new List<String>();
        for (Session__c session : sessionsList) {
            eventIds.add(session.Event__c);
        }
        
        List<Registration__c> registrationsList = [SELECT Id,Session__c FROM Registration__c WHERE Session__c IN :sessionsList ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
        //B2BGetInfo.saveOneSelection(registrationsList, registrationsList.get(0).Id);
    }

    @IsTest
    static void testUpdateAccountCurrency() {

        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalType = 'None' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
        
            // Create a test user and account
            Account account = new Account(Name='TestAccount', CurrencyIsoCode='USD');
            insert account;
            Contact contact = new Contact(AccountId=account.Id, LastName='TestContact');
            insert contact;

            // get System Admin profile
            Profile customerCommunityProfile = [SELECT Id FROM Profile WHERE Name = 'B2B Customer Community Plus User' LIMIT 1];

            // generate unique username string for User record
            String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@test.com';
        
            User user = new User(ContactId=contact.Id, ProfileId=customerCommunityProfile.Id, Alias='testuser', Email='testuser@test.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
            insert user;

            // insert buyer account
            BuyerAccount buyerAccount = new BuyerAccount(Name='Test Buyer Account', BuyerId=account.Id, CurrencyIsoCode='USD');
            insert buyerAccount;

            // Call the method to test
            Test.startTest();
            String result = B2BGetInfo.updateAccountCurrency('EUR', user.Id);
            Test.stopTest();

            // Verify the result
            System.assertEquals('success', result, 'Result should be success');

            // Verify that the account currency was updated
            Account updatedAccount = [SELECT CurrencyIsoCode FROM Account WHERE Id = :account.Id];
            System.assertEquals('EUR', updatedAccount.CurrencyIsoCode, 'Account currency should be EUR');

            // Verify that the buyer account currency was updated
            BuyerAccount updatedBuyerAccount = [SELECT CurrencyIsoCode FROM BuyerAccount WHERE BuyerId = :account.Id];
            System.assertEquals('EUR', updatedBuyerAccount.CurrencyIsoCode, 'Buyer account currency should be EUR');
        }
    }

    @IsTest(SeeAllData=true)
    static void testGetGbpProductPrice() {
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = :B2BGetInfo.TTS_PRICEBOOK LIMIT 1];
        
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description'
        );
        insert product;

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

        Test.startTest();
        String result = B2BGetInfo.getGbpProductPrice(product.Id);
        Test.stopTest();

        // Verify that the result is not null
        Assert.isNotNull(result, 'Result should not be null');
    }

    @IsTest(SeeAllData=true)
    static void testGetOnlyOneSession() {
		Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Seats_Available__c = 10);
        insert testCampaign;

        Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
        insert testSession;

        // Pricebook2 standardPricebook = new Pricebook2(
        //     Id = Test.getStandardPricebookId(),
        //     IsActive = true
        // );

        // update standardPricebook;

        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = :B2BGetInfo.TTS_PRICEBOOK LIMIT 1];
        
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description',
            TTS_Event__c = testCampaign.Id
        );
        insert product;

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

        Test.startTest();
        	B2BGetInfo.getOnlyOneSession(product.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpdateSessionPricesOnCart(){
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
            Pricebook2 testPB = SIB_TestDataFactory.createCommercePricebook2('TTS B2B Store Price Book',true);
            List<PricebookEntry> testPBE = SIB_TestDataFactory.createPricebookEntry(testPB.Id,new List<Product2>{product,product2},true);

            CartItem cartItem = new CartItem(
                CartId = testWebCart.id, 
                Sku = 'TestSKU',
                Quantity = 3.0,
                Type = SIB_Constants.PRODUCT, 
                Name = 'TestProduct', 
                CurrencyIsoCode = 'USD',
                Product2Id = product.id,
                Number_of_Sessions__c= 10,
                CartDeliveryGroupId = testCDG.Id);
            insert cartItem;

            CartItem cartItem2 = new CartItem(
                CartId = testWebCart.id, 
                Sku = 'TestSKU2',
                Quantity = 3.0,
                Type = SIB_Constants.PRODUCT, 
                Name = 'TestProduct2', 
                CurrencyIsoCode = 'USD',
                Product2Id = product2.id,
                Number_of_Sessions__c= 10,
                CartDeliveryGroupId = testCDG.Id);
            insert cartItem2;

            CartItem cartItem3 = new CartItem(
                CartId = testWebCart.Id, 
                Sku = 'TestSKU3',
                Quantity = 3.0,
                Type = SIB_Constants.PRODUCT, 
                Name = 'TestProduct3', 
                CurrencyIsoCode = 'USD',
                Product2Id = product.id,
                Number_of_Sessions__c= 0,
                CartDeliveryGroupId = testCDG.Id);
            insert cartItem3;
            Test.startTest();
            B2BGetInfo.updateSessionPricesOnCart(testWebCart.Id);
            Test.stopTest();
        }
        
    }

    @isTest
    static void testsaveOneSelection(){
        BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
        Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
        Contact testContact = SIB_TestDataFactory.createContact(testAccount,true);
        User managerUser = new User();
        managerUser.Alias = 'test123';
        managerUser.Username = 'testxyz@yopmail.com';
        managerUser.Email = 'testxyz@yopmail.com';
        managerUser.Phone = '1234567894';
        managerUser.MobilePhone = '1234567894';
        managerUser.FirstName = 'TestBuyerContact';
        managerUser.LastName = 'TestBuyerContact';
        managerUser.ContactId = testContact.Id;
        managerUser.Title = 'Manager';
        managerUser.CommunityNickName = 'test123';
        Profile p = [Select Id, Name FROM profile WHERE Name='B2B Customer Community Plus Login User'];
        managerUser.ProfileId = p.Id;
        managerUser.TimeZoneSidKey = 'America/Los_Angeles';
        managerUser.LocaleSidKey = 'en_US';
        managerUser.EmailEncodingKey = 'ISO-8859-1';
        managerUser.LanguageLocaleKey = 'en_US';
        managerUser.FederationIdentifier = 'Test123';
        managerUser.PortalRole = 'Manager';
        insert managerUser;
        
        System.runAs(managerUser){
          
            
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

            Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
            insert testSession;
            Registration__c testReg = new Registration__c();
            testreg.Waiting_List__c = true; 
            testreg.Session__c = testSession.Id;
            testreg.Contact__c = testContact.Id;            
            insert testReg;

            Test.startTest();
            Registration__c testresult = B2BGetInfo.saveOneSelection(new List<Registration__c>{testReg},testSession.Id);
            Test.stopTest();
        }
        
    }


}