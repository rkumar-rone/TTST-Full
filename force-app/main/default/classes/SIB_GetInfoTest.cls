/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-08-2024
 * @last modified by  : Gaurav Setia
**/
@isTest
public class SIB_GetInfoTest {


    @isTest
    static void testGetGroupRecipientsForCart(){
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        System.runAs(adminUser){
            WebStore testWebStore = SIB_TestDataFactory.createWebStore(true);
            BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
            Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
            Contact testContact = SIB_TestDataFactory.createContact(testAccount,true);
            WebCart testWebCart = SIB_TestDataFactory.createCart(testContact,adminUser,testWebStore,true);
            CartDeliveryGroup testCDG = SIB_TestDataFactory.createCartDeliveryGroup(testWebCart,true);

            Group_Recepient__c gr = new Group_Recepient__c(
                Recepient_Email__c = 'test345@yopmail.com',
                Status__c = 'Created',
                Cart__c = testWebCart.id,
                First_Name__c = 'test',
                Last_Name__c = 'test last name '
            );
            insert gr;

            Test.startTest();
            SIB_GetInfo.getGroupRecipientsForCart(testWebCart.Id);
            Test.stopTest();
        }

    }

    @isTest
    static void createGroupRecepientsTest(){
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        System.runAs(adminUser){
            WebStore testWebStore = SIB_TestDataFactory.createWebStore(true);
            BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
            Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
            Contact testContact = SIB_TestDataFactory.createContact(testAccount,true);
            WebCart testWebCart = SIB_TestDataFactory.createCart(testContact,adminUser,testWebStore,true);
            CartDeliveryGroup testCDG = SIB_TestDataFactory.createCartDeliveryGroup(testWebCart,true);

            Group_Recepient__c gr = new Group_Recepient__c(
                Recepient_Email__c = 'test345@yopmail.com',
                Status__c = 'Created',
                Cart__c = testWebCart.id,
                First_Name__c = 'test',
                Last_Name__c = 'test last name '
            );

            insert gr;

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

            Product2 product = new Product2(
                IsActive = true, 
                Name = 'Test Product', 
                StockKeepingUnit = 'TestSKU-1', 
                Description = 'Test Description',
                TTS_Event__c = testCampaign.Id,
                Product_Group__c = SIB_Constants.PRODUCT_GROUP_PUBLIC_COURSE
            );
            insert product;

            Pricebook2 testPB = SIB_TestDataFactory.createCommercePricebook2('TTS B2B Store Price Book',true);
            List<PricebookEntry> testPBE = SIB_TestDataFactory.createPricebookEntry(testPB.Id,new List<Product2>{product},true);

            CartItem cartItem = new CartItem(
                CartId = testWebCart.id, 
                Sku = 'TestSKU-1',
                Quantity = 3.0,
                Type = SIB_Constants.PRODUCT, 
                Name = 'TestProduct', 
                CurrencyIsoCode = 'USD',
                Product2Id = product.id,
                Number_of_Sessions__c= 10,
                CartDeliveryGroupId = testCDG.Id);
            insert cartItem;


            Test.startTest();
            SIB_GetInfo.createGroupRecepients(new List<Group_Recepient__c>{gr},false,testWebCart.Id);
            SIB_GetInfo.createGroupRecepients(new List<Group_Recepient__c>{gr},true,testWebCart.Id);
            
            Test.stopTest();
        }

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
            SIB_GetInfo.updateSessionPricesOnCart(testWebCart.Id);
            Test.stopTest();
        }
        
    }

    @isTest
    static void testUpdateSessionPricesOnCartItems(){
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
            SIB_GetInfo.updateSessionPricesOnCartItems(testWebCart.Id, product.id, 0, false, '');
            Test.stopTest();
        }
        
    }
}