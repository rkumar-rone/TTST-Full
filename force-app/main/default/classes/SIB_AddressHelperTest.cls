/**
 * @description       : Test class for SIB_AddressHelper
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_AddressHelperTest {
	@TestSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        ContactPointAddress cpa = new ContactPointAddress();
        cpa.Name='TestAdd';
        cpa.ParentId = acc.Id;
        cpa.AddressType = 'Billing';
        cpa.City = 'New York';
        cpa.CountryCode = 'US';
        cpa.StateCode= 'NY';
        cpa.Street='Test';
        cpa.PostalCode='010101';
        insert cpa;
        
        ContactPointAddress cpaShip = new ContactPointAddress();
        cpaShip.Name='TestAddShip';
        cpaShip.ParentId = acc.Id;
        cpaShip.AddressType = 'Shipping';
        cpaShip.City = 'New York';
        cpaShip.CountryCode = 'US';
        cpaShip.StateCode= 'NY';
        cpaShip.Street='Test';
        cpaShip.PostalCode='010101';
        insert cpaShip;
        
        String storeName = SIB_Util.fetchConfigByValue(SIB_Constants.STOREFRONT_MODULE);
        Webstore webstore = new Webstore(Name = storeName);
        insert webstore;
        
        WebCart cart = new WebCart();
        cart.AccountId = acc.Id;
        cart.Name = 'Test Cart';
        cart.Status = 'Active';
        cart.Type = 'Cart';
        cart.WebStoreId = webstore.Id;
        insert cart;
        
        CartDeliveryGroup cdg = new CartDeliveryGroup();
        cdg.Name = 'Default Delivery';
        cdg.CartId = cart.Id;
        insert cdg;
    }
    
    @isTest
    static void getContactPointAddressesTest(){
        Account acc = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.BILLING_ACCOUNT_ID, acc.Id);
        Test.startTest();
        dataMap = SIB_AddressHelper.getContactPointAddresses(dataMap);
        Test.stopTest();
        system.assertEquals(null,dataMap.get(SIB_Constants.IS_SUCCESS),'getContactPointAddressesTest assertion failed');
    }
    
     @isTest
     static void updateCartWithCPATest(){
         Map<String,Object> dataMap = new Map<String,Object>();
         WebCart cart = [SELECT Id FROM WebCart ORDER BY CreatedDate DESC LIMIT 1];
         ContactPointAddress cpa = [SELECT Id,Name,ParentId,AddressType,City,CountryCode,StateCode,PostalCode,Street 
                                    FROM ContactPointAddress ORDER BY CreatedDate DESC LIMIT 1];
         dataMap.put(SIB_Constants.CART_ID, cart.Id);
         dataMap.put(SIB_Constants.ADDRESS, cpa);
         Test.startTest();
         dataMap = SIB_AddressHelper.updateCartWithCPA(dataMap);
         Test.stopTest();
         system.assertEquals(null,dataMap.get(SIB_Constants.IS_SUCCESS),'updateCartWithCPATest assertion failed');
    }
    
    @isTest
    static void getAllAddressesForAccountTest(){
        Account acc = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('accountId',acc.Id);
        Test.startTest();
        dataMap = SIB_AddressHelper.getAllAddressesForAccount(dataMap);
        Test.stopTest();
        system.assertEquals(true,dataMap.get('isSuccess'),'getAllAddressesForAccountTest assertion failed');
    }
}