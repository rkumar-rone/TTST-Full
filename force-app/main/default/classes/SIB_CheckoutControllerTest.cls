@isTest
public with sharing class SIB_CheckoutControllerTest {

    private static Map<String, Object> requestMap;
    
    @isTest
    static void getCheckoutConfigurationTest(){
        requestMap = new Map<String, Object>();
        
        Test.startTest();
        
        SIB_CheckoutController.getCheckoutConfiguration(requestMap);
        SIB_CheckoutController.getCheckoutConfiguration(null);
        Test.stopTest();
        
    }
    
    @isTest
    static void getGroupOrderInformationTest(){
        requestMap = new Map<String, Object>();
        
        Test.startTest();
        SIB_CheckoutController.getGroupOrderInformation(requestMap);

        List<String> cartIds = new List<String>();
        requestMap.put(SIB_Constants.CARTID, cartIds);
        SIB_CheckoutController.getGroupOrderInformation(requestMap);
        Test.stopTest();
    }

    @isTest
    static void updateCartAndCartItems(){
        requestMap = new Map<String, Object>();
        
        Test.startTest();
            SIB_CheckoutController.updateCartAndCartItems(requestMap);

            List<String> cartIds = new List<String>();
            requestMap.put(SIB_Constants.PARAM_CARTTOUPDATE, cartIds);
            SIB_CheckoutController.updateCartAndCartItems(requestMap);
        Test.stopTest();
    }

    @isTest
    static void checkEmailIsAlreadyOnColleva(){
        requestMap = new Map<String, Object>();
        
        Test.startTest();
            SIB_CheckoutController.checkEmailIsAlreadyOnColleva(requestMap);

            List<String> cartIds = new List<String>();
            requestMap.put(SIB_Constants.PARAM_CARTTOUPDATE, cartIds);
            SIB_CheckoutController.checkEmailIsAlreadyOnColleva(requestMap);
        Test.stopTest();
    }

    
}