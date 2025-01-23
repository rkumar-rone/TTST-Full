/**
 * @description       :
 * @author            : Gaurang Arora
 * @group             :
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_ComponentConfigHelperTest {
	@TestSetup
    static void setup(){
        SIB_Community_Component_Config__c test = new SIB_Community_Component_Config__c();
        test.Component_Name__c='test';
        insert test;
    }
    @isTest
    static void getComponentConfigJsonTest(){
        String response;
        Test.startTest();
        response = SIB_ComponentConfigHelper.getComponentConfigJson('test');
        Test.stopTest();
        system.assertEquals(true,response.length()>0,'getComponentConfigJsonTest assertion failed');
    }
    @isTest
    static void saveSettingsTest(){
        Test.startTest();
        SIB_ComponentConfigHelper.saveSettings('','test','test','test');
        Test.stopTest();
    }
    
    @isTest
    static void saveSettingsExceptionTest(){
        SIB_Community_Component_Config__c config = [SELECT Id FROM SIB_Community_Component_Config__c LIMIT 1];
        Test.startTest();
        SIB_ComponentConfigHelper.saveSettings(config.Id,'test','test','test');
        Test.stopTest();
    }
}