/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 10-30-2024
 * @last modified by  : Gaurav Setia
**/
@isTest
public class SIB_UtilTest {
    
    @TestSetup
    static void setup(){
        Account account = new Account (Name = 'test');
        insert account;
        WebStore webStore = new WebStore(Name='test');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Quantity = 2, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
    }
    
	@isTest
    static void getAllObjectFieldsTest(){
        Test.startTest();
        String response = SIB_Util.getAllObjectFields('Account');
        Test.stopTest();
        system.assertEquals(true,response.length()>0,'getAllObjectFieldsTest assertion failed');
    }
    
    @isTest
    static void getRegistrationBuyerGroupNameTest(){
		Test.startTest();
		String response = SIB_Util.getRegistrationBuyerGroupName();
		Test.stopTest();  
        system.assertEquals(true,response.length()>0,'getRegistrationBuyerGroupNameTest assertion failed');
    }
    
    @isTest
    static void getRegistrationProfileNameTest(){
		Test.startTest();
		String response = SIB_Util.getRegistrationProfileName();
		Test.stopTest();  
        system.assertEquals(true,response.length()>0,'getRegistrationProfileNameTest assertion failed');
    }
    
    @isTest
    static void getBuyerPermissionSetNameTest(){
		Test.startTest();
		List<String> response = SIB_Util.getBuyerPermissionSetName();
		Test.stopTest();  
        system.assertEquals(true,response.size()>0,'getBuyerPermissionSetNameTest assertion failed');
    }
    
    @isTest
    static void getTimeZoneSidKeyTest(){
		Test.startTest();
		String response = SIB_Util.getTimeZoneSidKey();
		Test.stopTest();  
        system.assertEquals(true,response.length()>0,'getTimeZoneSidKeyTest assertion failed');
    }
    
    @isTest
    static void getLocaleSidKeyTest(){
		Test.startTest();
		String response = SIB_Util.getLocaleSidKey();
		Test.stopTest();  
        system.assertEquals(true,response.length()>0,'getLocaleSidKeyTest assertion failed');
    }
    
    @isTest
    static void getLanguageLocaleKeyTest(){
		Test.startTest();
		String response = SIB_Util.getLanguageLocaleKey();
		Test.stopTest();  
        system.assertEquals(true,response.length()>0,'getLanguageLocaleKeyTest assertion failed');
    }
    
	@isTest
    static void fetchConfigByModuleTest(){
        Test.startTest();
        List<String> response = SIB_Util.fetchConfigByModule('SelfStudyCategory');
        Test.stopTest();
        system.assertEquals(true,response.size()>0,'fetchConfigByModuleTest assertion failed');
    } 
    
    @isTest
    static void fetchConfigMapByModuleTest(){
        Test.startTest();
        Map<String,Object> response = SIB_Util.fetchConfigMapByModule('SelfStudyCategory');
        Test.stopTest();
        system.assertEquals(true,response.size()>0,'fetchConfigMapByModuleTest assertion failed');
    } 
    
    @isTest
    static void checkForGroupOrderCartTest(){
        List<CartItem> cartItems = [SELECT Id,Quantity FROM CartItem];
        Test.startTest();
        Boolean response = SIB_Util.checkForGroupOrderCart(cartItems);
       	Test.stopTest();
        system.assertEquals(false,response,'checkForGroupOrderCartTest assertion failed');   
    }
    
    @isTest
    static void isSandboxOrgTest(){
        Test.startTest();
        Boolean response = SIB_Util.isSandboxOrg();
        Test.stopTest();
    }
    
    @isTest
    static void makeHttpCalloutTest(){
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.HTTP_ENDPOINT,'test');
        dataMap.put(SIB_Constants.HTTP_AUTHORIZATION_HEADER,'test');
        dataMap.put(SIB_Constants.HTTP_METHOD,'test');
        dataMap.put(SIB_Constants.HTTP_METHOD,'test');
        dataMap.put(SIB_Constants.HTTP_AUTHORIZATION_HEADER,'BASIC');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SIB_CourseReviewBatchMock());
        dataMap = SIB_Util.makeHttpCallout(dataMap);
        Test.stopTest();
        String response = (String)dataMap.get(SIB_Constants.HTTP_RESPONSE);
        system.assertEquals(true,response.length()>0,'makeHttpCalloutTest assertion failed');   
    }
    
    @isTest
    static void updateSObjectsListTest(){
        List<Account> accs = [SELECT Id FROM Account];
        Test.startTest();
        List<Account> response = (List<sObject>) SIB_Util.updateSObjectsList(accs);
        Test.stopTest();
        system.assertEquals(accs[0].Id,response[0].Id,'updateSObjectsListTest assertion failed');
    }
    
    // @isTest
    // static void getNetworkIdTest(){
    //     Test.startTest();
    //     String response = SIB_Util.getNetworkId();
    //     Test.stopTest();
    // }
}