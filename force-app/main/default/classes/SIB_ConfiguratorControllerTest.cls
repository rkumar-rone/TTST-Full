/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 10-09-2024
 * @last modified by  :
**/
@isTest
public class SIB_ConfiguratorControllerTest {
	@TestSetup
    static void setup(){
        SIB_Configurator_Config__c test = new SIB_Configurator_Config__c();
        test.Name='test';
        insert test;
    }
    
    @isTest
    static void saveConfiguratorColorSettingsTest(){
        Test.startTest();
        SIB_ConfiguratorController.saveConfiguratorColorSettings('test');
        Test.stopTest();
    }
    
    @isTest
    static void saveConfiguratorTypographySettingsTest(){
        Test.startTest();
        SIB_ConfiguratorController.saveConfiguratorTypographySettings('test');
        Test.stopTest();
    }
    
    @isTest
    static void saveConfiguratorTemplateSettingsTest(){
        Test.startTest();
        SIB_ConfiguratorController.saveConfiguratorTemplateSettings('Generateo');
        Test.stopTest();
    }
    @isTest
    static void saveConfiguratorTemplateSettingsExceptionTest(){
        Test.startTest();
        SIB_ConfiguratorController.saveConfiguratorTemplateSettings('Exception');
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorColorSettingsTest(){
        Test.startTest();
        String response = SIB_ConfiguratorController.getConfiguratorColorSettings();
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorColorSettingsExceptionTest(){
        SIB_Configurator_Config__c config = [SELECT Id FROM SIB_Configurator_Config__c LIMIT 1];
        delete config;
        Test.startTest();
        String response = SIB_ConfiguratorController.getConfiguratorColorSettings();
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorTypographySettingsTest(){
        Test.startTest();
        String response = SIB_ConfiguratorController.getConfiguratorTypographySettings();
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorTypographySettingsExceptionTest(){
        SIB_Configurator_Config__c config = [SELECT Id FROM SIB_Configurator_Config__c LIMIT 1];
        delete config;
        Test.startTest();
        String response = SIB_ConfiguratorController.getConfiguratorTypographySettings();
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorTemplateSettingsTest(){
        Test.startTest();
        String response = SIB_ConfiguratorController.getConfiguratorTemplateSettings();
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorTemplateSettingsExceptionTest(){
        SIB_Configurator_Config__c config = [SELECT Id FROM SIB_Configurator_Config__c LIMIT 1];
        delete config;
        Test.startTest();
        String response = SIB_ConfiguratorController.getConfiguratorTemplateSettings();
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorSettingsTest(){
        Test.startTest();
        SIB_Configurator_Config__c response = SIB_ConfiguratorController.getConfiguratorSettings();
        Test.stopTest();
    }
    
    @isTest
    static void getConfiguratorSettingsExceptionTest(){
        SIB_Configurator_Config__c config = [SELECT Id FROM SIB_Configurator_Config__c LIMIT 1];
        delete config;
        Test.startTest();
        SIB_Configurator_Config__c response = SIB_ConfiguratorController.getConfiguratorSettings();
        Test.stopTest();
    }
    
    @isTest
    static void getStorefrontConfigurationSettingsTest(){
        Test.startTest();
        SIB_StorefrontConfiguration__c response = SIB_ConfiguratorController.getStorefrontConfigurationSettings();
        Test.stopTest();
    }
    
    
}