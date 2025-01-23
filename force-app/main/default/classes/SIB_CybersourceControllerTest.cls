/**
 * @description       : 
 * @author            : vramachandran@rafter.one
 * @group             : 
 * @last modified on  : 10-10-2024
 * @last modified by  : vramachandran@rafter.com
**/
@isTest
public class SIB_CybersourceControllerTest {

    private static final SIB_CybersourceController controller;

    @isTest
    static void generateKeyTest() {

        Test.startTest();
        SIB_CybersourceController.generateKey(null);
        Test.stopTest();
    }

    @isTest
    static void proceedToPaymentTest() {
        Map<String, Object> paymentMap = new Map<String, Object>{
            'testdata' => 'test'
        };

            Map<String, Object> failPaymentMap = new Map<String, Object>{
            SIB_Constants.ACCOUNT_ID => new WebCart()
        };
            
        Test.startTest();
        SIB_CybersourceController.proceedToPayment(paymentMap);
        SIB_CybersourceController.proceedToPayment(failPaymentMap);
        Test.stopTest();
    }

    @isTest
    static void updatePaymentMethodOnCartTest() {
        Map<String, Object> paymentMap = new Map<String, Object>{
            'testdata' => 'test'
        };
            
            Map<String, Object> failPaymentMap = new Map<String, Object>{
                SIB_Constants.CARTID => new WebCart()
            };

        Test.startTest();
        SIB_CybersourceController.updatePaymentMethodOnCart(paymentMap);
        SIB_CybersourceController.updatePaymentMethodOnCart(failPaymentMap);
        Test.stopTest();

    }
    
    @isTest
    static void capturePaymentAuthorizationTest() {
        Map<String, Object> paymentMap = new Map<String, Object>{
            'testdata' => 'test'
        };
            
            Map<String, Object> failPaymentMap = new Map<String, Object>{
                SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID => new WebCart()
            };
        
        Test.startTest();
        SIB_CybersourceController.capturePaymentAuthorization(paymentMap);
        SIB_CybersourceController.capturePaymentAuthorization(failPaymentMap);
        Test.stopTest();
    }
    
    @isTest
    static void getAccountInformationTest() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, Object> failRequestMap = new Map<String, Object>{
            SIB_Constants.PARAM_EFFECTIVEACCOUNTID => new WebCart()
        };
            
        Test.startTest();
        SIB_CybersourceController.getAccountInformation(requestMap);
        SIB_CybersourceController.getAccountInformation(failRequestMap);
        Test.stopTest();
    }
    
    @isTest
    static void revertAuthorizationTest() {
        
        Map<String, Object> requestMap = new Map<String, Object>{
            'testData' => 'test'
        };
        
            Map<String, Object> failRequestMap = new Map<String, Object>{
                SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID => new WebCart()
            };
            
        Test.startTest();
        SIB_CybersourceController.revertAuthorization(requestMap);
        SIB_CybersourceController.revertAuthorization(failRequestMap);
        Test.stopTest();
            
    }
   
    
    @isTest
    static void getCartPaymentStatusTest() {
        
        Map<String, Object> requestMap = new Map<String, Object>{
            'testData' => 'test'
        };
            
            Map<String, Object> failRequestMap = new Map<String, Object>{
                SIB_Constants.CARTID => new WebCart()
            };
        
        Test.startTest();
        SIB_CybersourceController.getCartPaymentStatus(requestMap);
        SIB_CybersourceController.getCartPaymentStatus(failRequestMap);
        Test.stopTest();
    }
    
    @isTest
    static void getPaymentModuleTest() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        requestMap.put(SIB_Constants.MODULE_NAME, 'Payment');
        
        Test.startTest();
        SIB_CybersourceController.getPaymentModule(requestMap);
        requestMap.put(SIB_Constants.MODULE_NAME, new WebCart());
        SIB_CybersourceController.getPaymentModule(requestMap);
        Test.stopTest();
    }
    
    @isTest
    static void getAuthorizationInformationTest() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        requestMap.put(SIB_Constants.PARAM_PAYMENT_METHODID, 'paymentMethodId');
        requestMap.put(SIB_Constants.PARAM_PAYMENT_GROUPID, 'paymentGroupId');
        
        Test.startTest();
        SIB_CybersourceController.getAuthorizationInformation(requestMap);
        requestMap.put(SIB_Constants.PARAM_PAYMENT_METHODID, new WebCart());
        SIB_CybersourceController.getAuthorizationInformation(requestMap);
        Test.stopTest();
    }
    
    
}