/**
 * @description       : Test class for SIB_AddressSelector
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_AddressSelectorTest {
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
    static void getAddressesByAccountIdsAndAddressType(){
        Account acc = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        List<ContactPointAddress> cpa = new List<ContactPointAddress>();
        Test.startTest();
        cpa = (List<ContactPointAddress>) SIB_AddressSelector.getAddressesByAccountIdsAndAddressType(new List<Id>{acc.Id},'Billing');
        Test.stopTest();
        system.assertEquals(1,cpa.size(),'getAddressesByAccountIdsAndAddressType Assertion failed');
    }
    
     @isTest
     static void getAddressesByAccountIdsTest(){
        Account acc = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
       	List<ContactPointAddress> cpa = new List<ContactPointAddress>();
        Test.startTest();
        cpa = (List<ContactPointAddress>) SIB_AddressSelector.getAddressesByAccountIds(new List<Id>{acc.Id});
        Test.stopTest();
        system.assertEquals(2,cpa.size(),'getAddressesByAccountIdsTest Assertion failed');
    }

}