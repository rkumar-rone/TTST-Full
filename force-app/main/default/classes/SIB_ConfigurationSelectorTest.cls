/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 10-09-2024
 * @last modified by  : Gaurang Arora
**/
@isTest
public class SIB_ConfigurationSelectorTest {
	@TestSetup
    static void setup(){
        SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
        testConfig.Active__c = true;
        testConfig.ConfigurationType__c = 'CART';
        insert testConfig;
    }
    
    @isTest
    static void getConfigurationSelectorByType(){
        Test.startTest();
        Sobject obj = SIB_ConfigurationSelector.getConfigurationSelectorByType('CART');
        Test.stopTest();
    }
    
    @isTest
    static void getConfigurationSelectorByIdTest(){
        SIB_StorefrontConfiguration__c config = [SELECT Id FROM SIB_StorefrontConfiguration__c LIMIT 1];
        Test.startTest();
        SObject obj = SIB_ConfigurationSelector.getConfigurationSelectorById(config.Id);
        Test.stopTest();
    }
}