/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_UserRegistrationHelperTest {
    @TestSetup
    static void setup(){
    	String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@invalid.com';
        User u = new User();
        u.Username = uniqueUserName;
        u.LastName = 'TestLastName';
        u.Email = 'test@invalid26.com';
        u.Alias = 'test2';
        u.TimeZoneSidKey = 'America/New_York';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = [select id from Profile where Name = 'Standard User'].Id;
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.IsActive = true;

        insert u;
    }
	@isTest
    static void validateRequestTest(){
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put(SIB_Constants.FIRSTNAME,'test');
        dataMap.put(SIB_Constants.LASTNAME,'test');
        dataMap.put(SIB_Constants.EMAIL,'test');
        dataMap.put(SIB_Constants.COMPANY,'test');
        dataMap.put(SIB_Constants.PHONE,'test');
        Test.startTest();
        Boolean response = SIB_UserRegistrationHelper.validateRequest(dataMap);
        Test.stopTest();
        system.assertEquals(true,response,'validateRequestTest assertion failed');
    }
    
    @isTest
    static void checkUserExistsTest(){
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.EMAIL,'test@invalid26.com');
        Test.startTest();
        User u = SIB_UserRegistrationHelper.checkUserExists(dataMap);
        Test.stopTest();
        system.assertEquals('TestLastName',u.Name,'checkUserExistsTest assertion failed'); 
    }
    
    @isTest
    static void createAccountTest(){
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put(SIB_Constants.COUNTRY_CODE,'US');
        dataMap.put(SIB_Constants.STATE_CODE,'NY');
        dataMap.put(SIB_Constants.COMPANY,'Test');
        Test.startTest();
        Account acc = SIB_UserRegistrationHelper.createAccount(dataMap);
        Test.stopTest();
        system.assertEquals('NY',acc.BillingStateCode,'createAccountTest assertion failed'); 
    }
    
    @isTest
    static void createContactTest(){
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put(SIB_Constants.COUNTRY_CODE,'US');
        dataMap.put(SIB_Constants.STATE_CODE,'NY');
        dataMap.put(SIB_Constants.LASTNAME,'Test');
        Test.startTest();
        Contact con = SIB_UserRegistrationHelper.createContact(dataMap);
        Test.stopTest();
        system.assertEquals('NY',con.MailingStateCode,'createContactTest assertion failed'); 
    }
    
    @isTest
    static void createUserTest(){
    	Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put(SIB_Constants.FIRSTNAME,'test');
        dataMap.put(SIB_Constants.LASTNAME,'test');
        dataMap.put(SIB_Constants.FIRSTNAME,'test');
    	String uniqueUserName = 'testmethod' + DateTime.now().getTime() + '@invalid.com';
		dataMap.put(SIB_Constants.EMAIL,uniqueUserName);
		dataMap.put(SIB_Constants.EMAIL,uniqueUserName);
		Test.startTest();
        try{
        	User u = SIB_UserRegistrationHelper.createUser(dataMap);
        }
        catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void getProfileIdTest(){
        Test.startTest();
        try{
        	Id response = SIB_UserRegistrationHelper.getProfileId();
        }
        catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void enableBuyerAccountsTest(){
        Account acc = new Account(Name='test');
        insert acc;
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.ACCOUNT_ID,acc.Id);
        Test.startTest();
        try{
        	SIB_UserRegistrationHelper.enableBuyerAccounts(dataMap);
        }
        catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void getBuyerPermissionSetTest(){
        Test.startTest();
        List<PermissionSet> response = SIB_UserRegistrationHelper.getBuyerPermissionSet();
        Test.stopTest();
    }
    
    @isTest
    static void assignPermissionSetTest(){
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        SIB_UserRegistrationHelper.assignPermissionSet(u.Id);
        Test.stopTest();
    }
}