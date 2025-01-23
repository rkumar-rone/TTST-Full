/**
 * @description       :
 * @author            : Gaurang Arora
 * @group             :
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_ComponentConfigControllerTest {
	@TestSetup
    static void setup(){
        SIB_Community_Component_Config__c test = new SIB_Community_Component_Config__c();
        test.Component_Name__c='test';
        insert test;
    }
    @isTest
    static void getComponentConfigTest(){
        String response;
        Test.startTest();
        response = SIB_ComponentConfigController.getComponentConfig('test','test');
        Test.stopTest();
       	SIB_ComponentConfigResult responseParse = (SIB_ComponentConfigResult)JSON.deserialize(response,SIB_ComponentConfigResult.class); 
        system.assertEquals('test',responseParse.componentName,'getComponentConfigTest assertion failed');
    }
    @isTest
    static void saveComponentConfigSettingsTest(){
        Test.startTest();
        SIB_ComponentConfigController.saveComponentConfigSettings('','test','test','test');
        Test.stopTest();
    }
    
    @isTest
    static void saveComponentConfigSettingsExceptionTest(){
        SIB_Community_Component_Config__c config = [SELECT Id FROM SIB_Community_Component_Config__c LIMIT 1];
        Test.startTest();
        SIB_ComponentConfigController.saveComponentConfigSettings(config.Id,'test','test','test');
        Test.stopTest();
    }
    
    @isTest
    static void getBaseUrlTest(){
        Test.startTest();
        String response = SIB_ComponentConfigController.getBaseUrl();
        Test.stopTest();
    }
}