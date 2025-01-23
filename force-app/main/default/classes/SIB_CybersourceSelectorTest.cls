/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-01-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public with sharing class SIB_CybersourceSelectorTest {
    
    @isTest
    static void getPaymentConfigurationTest() {
        Test.startTest();
        SIB_CybersourceSelector.getPaymentConfiguration('label', true);
        Test.stopTest();
    }
    
    @isTest
    static void getCyberSourcePaymentGatewayIdTest() {
        Test.startTest();
		SIB_CybersourceSelector.getCyberSourcePaymentGatewayId('');        
        Test.stopTest();
    }
    
    @isTest
    static void getPaymentAuthorizationByIdTest(){

        Test.startTest();
        PaymentAuthorization paymentAuth = getPaymentAuthorization();
        
        SIB_CybersourceSelector.getPaymentAuthorizationById(paymentAuth?.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getCartPaymentStatusTest() {
        Test.startTest();
        SIB_CybersourceSelector.getCartPaymentStatus('');
        SIB_CybersourceSelector.getConvertedWebCartCurrency('');
        SIB_CybersourceSelector.getConvertedPaymentAuthorizationById('');
        Test.stopTest();
    }

    @isTest
    static void getPaymentAuthorizationByPmPgIdTest() {
        
         Test.startTest();
        PaymentAuthorization paymentAuth = getPaymentAuthorization();
        
        SIB_CybersourceSelector.getPaymentAuthorizationByPmPgId(paymentAuth?.PaymentMethodId, paymentAuth?.PaymentGroupId);
        Test.stopTest();
    }
    
    private static PaymentAuthorization getPaymentAuthorization() {
        PaymentGroup paymentGrpRecord = new PaymentGroup();
        insert paymentGrpRecord;
        
        PaymentAuthorization paymentAuth = new PaymentAuthorization();
        paymentAuth.Amount = 100.00;
        paymentAuth.ProcessingMode = 'External';
        paymentAuth.Status = 'Draft'; 
        paymentAuth.GatewayRefNumber = 'testgatewayreferencenumber';
        paymentAuth.PaymentGroup = paymentGrpRecord;
        paymentAuth.PaymentGroupId = paymentGrpRecord?.Id;
        //PaymentAuth.AccountId = getCurrentAccount()?.Id;
        
        AlternativePaymentMethod newPM = new AlternativePaymentMethod(Status='Active', ProcessingMode = 'External');
        insert newPM;
        paymentAuth.PaymentMethodId = newPM.Id;
        insert paymentAuth;

        return paymentAuth;
    }
}