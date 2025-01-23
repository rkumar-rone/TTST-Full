/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_FooterControllerTest {
	@TestSetup
    static void setup(){
        SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
        testConfig.Active__c = true;
        testConfig.ConfigurationType__c = 'FOOTER';
        insert testConfig;
    }
    
    @isTest
    static void getFooterConfigurationTest(){
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_SetupConstants.CONFIG_JSON,'{"id":"test"}');
        Test.startTest();
        mapParams = SIB_FooterController.getFooterConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'getFooterConfigurationTest assertion failed');
    }
    
    @isTest
    static void getFooterConfigurationExceptionTest(){
        SIB_StorefrontConfiguration__c config = [SELECT Id FROM SIB_StorefrontConfiguration__c LIMIT 1];
        delete config;
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_SetupConstants.CONFIG_JSON,'test');
        Test.startTest();
        mapParams = SIB_FooterController.getFooterConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'getFooterConfigurationExceptionTest assertion failed');        
    }
    
    @isTest
    static void getFooterConfigurationException2Test(){
        SIB_StorefrontConfiguration__c config = [SELECT Id FROM SIB_StorefrontConfiguration__c LIMIT 1];
        delete config;
        Map<String,Object> mapParams = new Map<String,Object>();
        String json ='{"id":"test"}';
        mapParams.put(SIB_SetupConstants.CONFIG_JSON,json);
        Test.startTest();
        mapParams = SIB_FooterController.getFooterConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'getFooterConfigurationException2Test assertion failed');                
    }
}