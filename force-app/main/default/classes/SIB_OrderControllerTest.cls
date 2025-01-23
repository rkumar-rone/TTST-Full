/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_OrderControllerTest {
    @TestSetup
    static void setup(){
        SIB_StorefrontConfiguration__c config = new SIB_StorefrontConfiguration__c();
        config.ConfigurationType__c = 'ORDER DETAILS';
        config.Active__c = true;
        insert config;
    }
    
	@isTest
    static void getOrderConfigurationTest(){
        Map<String,Object> mapParams = new Map<String,Object>();
        Test.startTest();
        mapParams = SIB_OrderController.getOrderConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get('isSuccess'),'getOrderConfigurationTest assertion failed');
    }
    
    @isTest
    static void getOrderDetailsTest(){
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('recordId','invlaid35505');
        Test.startTest();
        mapParams = SIB_OrderController.getOrderDetails(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get('isSuccess'),'getOrderDetailsTest assertion failed');
    }
}