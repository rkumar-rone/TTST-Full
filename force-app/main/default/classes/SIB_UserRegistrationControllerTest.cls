/**
 * @description       : Test class for  SIB_UserRegistrationController
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_UserRegistrationControllerTest {

    @isTest
    static void testGetRegistrationConfiguration(){
        SIB_StorefrontConfiguration__c testConfig =  SIB_TestDataFactory.createStorefrontConfiguration('SIGNUP',null);

        Map<String,Object> mapParams = new Map<String,Object>();
        Test.startTest();
        Map<String,Object> result = SIB_UserRegistrationController.getRegistrationConfiguration(mapParams);
        Map<String,Object> initUserRegistration = SIB_UserRegistrationController.initUserRegistration(mapParams);
        Map<String,Object> initUserLogin = SIB_UserRegistrationController.initUserLogin(mapParams);
        Map<String,Object> getStrivacityLoginUrl = SIB_UserRegistrationController.getStrivacityLoginUrl(mapParams);
        System.assertEquals(result.get(SIB_Constants.IS_SUCCESS),false,'passed');

        Test.stopTest();
    }

    @isTest
    static void testInitUserRegistration(){
        SIB_StorefrontConfiguration__c testConfig =  SIB_TestDataFactory.createStorefrontConfiguration('SIGNUP',null);

        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.FIRSTNAME,1234);
        mapParams.put(SIB_Constants.START_URL,1234);

        
        Test.startTest();
        Map<String,Object> initUserRegistration = SIB_UserRegistrationController.initUserRegistration(mapParams);
        Map<String,Object> getStrivacityLoginUrl = SIB_UserRegistrationController.getStrivacityLoginUrl(mapParams);
        System.assertEquals(initUserRegistration.get(SIB_Constants.IS_SUCCESS),false,'passed');
        Test.stopTest();
    }
    
}