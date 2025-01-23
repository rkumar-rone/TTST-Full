/**
 * @description       : Test Class for SIB_PaymentAdapter
 * @author            : 
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_PaymentAdapterTest {
	@isTest
    static void processRequestTest(){
        SIB_PaymentAdapter adapter = new SIB_PaymentAdapter();
        Test.startTest();
        commercepayments.GatewayResponse repsonse = adapter.processRequest(null); 
        System.assertEquals(repsonse,null,'Passed');
        Test.stopTest();
    }
    
    @isTest
    static void processRequestTest2(){
        SIB_CheckoutConfiguration paymentConfig = new SIB_CheckoutConfiguration();
        
        paymentConfig.creditCardGateway = 'Stripe';
        paymentConfig.creditCardGatewayClassMap = new Map<String, String>{
            'Stripe' => 'com.stripe.gateway',
            'PayPal' => 'com.paypal.gateway'
        };
        String jsonSerialized = JSON.serialize(paymentConfig);

        SIB_PaymentAdapter adapter = new SIB_PaymentAdapter();
        SIB_StorefrontConfiguration__c testConfig =  SIB_TestDataFactory.createStorefrontConfiguration('CHECKOUT',jsonSerialized);

        Test.startTest();
        commercepayments.GatewayResponse repsonse = adapter.processRequest(null); 
        System.assertnotEquals(repsonse,null,'Passed');
        Test.stopTest();
    }

    @isTest
    static void processRequestTestNullJSON(){
        SIB_CheckoutConfiguration paymentConfig = new SIB_CheckoutConfiguration();
        paymentConfig.creditCardGateway = null;
        paymentConfig.creditCardGatewayClassMap = new Map<String, String>{
            'Stripe' => 'com.stripe.gateway',
            'PayPal' => 'com.paypal.gateway'
        };
        String jsonSerialized = JSON.serialize(paymentConfig);

        SIB_PaymentAdapter adapter = new SIB_PaymentAdapter();
        SIB_StorefrontConfiguration__c testConfig =  SIB_TestDataFactory.createStorefrontConfiguration('CHECKOUT',jsonSerialized);

        Test.startTest();
        commercepayments.GatewayResponse repsonse = adapter.processRequest(null); 
        System.assertnotEquals(repsonse,null,'Passed');
        Test.stopTest();
    }

    @isTest
    static void processRequestTestGateWay(){
        SIB_CheckoutConfiguration paymentConfig = new SIB_CheckoutConfiguration();
        paymentConfig.creditCardGateway = 'ipay';
        paymentConfig.creditCardGatewayClassMap = new Map<String, String>{
            'Stripe' => 'com.stripe.gateway',
            'PayPal' => 'com.paypal.gateway'
        };
        String jsonSerialized = JSON.serialize(paymentConfig);

        SIB_PaymentAdapter adapter = new SIB_PaymentAdapter();
        SIB_StorefrontConfiguration__c testConfig =  SIB_TestDataFactory.createStorefrontConfiguration('CHECKOUT',jsonSerialized);

        Test.startTest();
        commercepayments.GatewayResponse repsonse = adapter.processRequest(null); 
        System.assertnotEquals(repsonse,null,'Passed');
        Test.stopTest();
    }
}