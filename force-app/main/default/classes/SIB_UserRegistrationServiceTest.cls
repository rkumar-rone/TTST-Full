/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_UserRegistrationServiceTest {

    @isTest
    static void testGetRegistrationConfiguration(){
        SIB_SignUpConfiguration config = new SIB_SignUpConfiguration();
        config.id = '12345';
        config.cssTheme = 'dark';
        config.showPasswordFields = true;
        String jsonData = JSON.serialize(config);
        Map<String,Object> mapParams = new Map<String,Object>();
        
        SIB_StorefrontConfiguration__c testConfig =  SIB_TestDataFactory.createStorefrontConfiguration('SIGNUP',jsonData);
        Test.startTest();
        Map<String,Object> result = SIB_UserRegistrationService.getRegistrationConfiguration(mapParams);
        mapParams.put(SIB_Constants.EMAIL, 'Test123@yopMail.com');
        mapParams.put(SIB_Constants.PASSWORD, 'TestPassword');
        mapParams.put(SIB_Constants.COMMUNITY_PATH, '');
        mapParams.put(SIB_Constants.START_URL, 'Test');

        
        Map<String,Object> resultGetLoginURL = SIB_UserRegistrationService.getLoginURL(mapParams);
        Map<String,Object> resultgetStrivacityLoginUrl = SIB_UserRegistrationService.getStrivacityLoginUrl(mapParams);
        System.assertEquals(result.get(SIB_Constants.IS_SUCCESS),true,'passed');
        Test.stopTest();

    }

    @isTest
    static void testRegisterNewUserSuccess() {
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put(SIB_Constants.EMAIL, 'testuser@example.com');
        dataMap.put(SIB_Constants.PASSWORD, 'Password123');
        dataMap.put(SIB_Constants.CONFIRM_PASSWORD, 'Password123');
        dataMap.put(SIB_Constants.COMPANY, 'Test Company');
        dataMap.put(SIB_Constants.COMPANYWEB, 'www.testcompany.com');
        dataMap.put(SIB_Constants.PHONE, '1234567890');
        dataMap.put(SIB_Constants.COUNTRY_CODE, 'US');
        dataMap.put(SIB_Constants.FIRSTNAME, 'John');
        dataMap.put(SIB_Constants.LASTNAME, 'Doe');

        BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);
        Test.startTest();
        Map<String, Object> result = SIB_UserRegistrationService.registerUser(dataMap);
        
        Test.stopTest();
        
        System.assertEquals(result.get(SIB_Constants.IS_SUCCESS), true, 'User creation should be successful');
    }
}