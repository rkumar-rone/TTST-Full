/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 11-01-2024
 * @last modified by  : Gaurang Arora
**/
@isTest
public class SIB_ConfigurationServiceTest {
	@TestSetup
    static void setup(){

        Account acc = new Account();
        acc.Name = 'Doe INC';
        acc.Website = 'https://www.rafterone.com';
        acc.Phone = '9876543210';
        acc.BillingCountryCode = 'US';
        acc.BillingStateCode = 'GA';
        insert acc;

        Contact customerContact = new Contact();
        customerContact.AccountId = acc.Id;
        customerContact.FirstName = 'Smith';
        customerContact.LastName = 'Doe';
        customerContact.Email = 'sdoe@yopmail.com';
        customerContact.Phone = '9876543210';
        customerContact.MailingCountryCode = 'US';
        customerContact.MailingStateCode = 'GA';
        customerContact.Strivacity_Identifier__c = 'Test12332';
        
        insert customerContact;

        User managerUser = new User();
        managerUser.Alias = 'test123';
        managerUser.Username = 'testxyz@yopmail.com';
        managerUser.Email = 'testxyz@yopmail.com';
        managerUser.Phone = '1234567894';
        managerUser.MobilePhone = '1234567894';
        managerUser.FirstName = 'TestBuyerContact';
        managerUser.LastName = 'TestBuyerContact';
        managerUser.ContactId = customerContact.Id;
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



        SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
        testConfig.Active__c = true;
        testConfig.ConfigurationType__c = 'CART';
        insert testConfig;
    }
    @isTest
    static void getConfigurationJSONTest(){
        User thisUser = [SELECT Id FROM User Where Lastname ='TestBuyerContact'];
    
        System.runAs(thisUser) {
            Map<String,Object> mapParams = new Map<String,Object>();
            mapParams.put('configurationType','CART');
            Test.startTest();
            mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
            Map<String,Object> mapParam = SIB_ConfigurationService.getEncryptedFederationId();
            Test.stopTest();
        }
       
    }
}