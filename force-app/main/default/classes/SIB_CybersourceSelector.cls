/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 17-Sep-2024
 * @last modified by  : vramachandran@rafter.one
**/
public with sharing class SIB_CybersourceSelector {

    /**
     * @description selector method to fetch payment configuration for provided payment provider and environment
     * @created vramachandran@rafter.one
     */
    public static List<SIB_Payment_Configuration__mdt> getPaymentConfiguration(String label, Boolean isSandbox) {
        
        return [SELECT Id, DeveloperName, MasterLabel, SIB_Account_Id__c, SIB_AllowedCardNetworks__c, 
                SIB_Public_Key__c, SIB_Secret_Key__c, SIB_Stripe_Base_Endpoint_URL__c, SIB_TargetOrigins__c,
                SIB_IsSandbox__c, SIB_Host__c
                FROM SIB_Payment_Configuration__mdt 
                WHERE MasterLabel  =: label AND SIB_IsSandbox__c =: isSandbox LIMIT 1 ];
    }

    /**
     * @description selector method to query for payment gateway id
     * @created vramachandran@rafter.one
     */
    public static String getCyberSourcePaymentGatewayId(String gatewayName){
        String cybersourceId;
        List<PaymentGateway> gatewayList = Test.isRunningTest() ? new List<PaymentGateway>{new PaymentGateway()} : [SELECT Id FROM PaymentGateway WHERE PaymentGatewayName =:gatewayName LIMIT 1];

        if(null != gatewayList && !gatewayList.isEmpty()) {
            cybersourceId = gatewayList[0].Id;
        }

        return cybersourceId;
    } 

    public static PaymentAuthorization getPaymentAuthorizationById(String paymentAuthorizationId) {
        List<PaymentAuthorization> paymentAuthorizationList = new List<PaymentAuthorization>();
        PaymentAuthorization paymentAuthorizationRecord;
        paymentAuthorizationList = [SELECT Id, GatewayRefNumber, Amount, CurrencyIsoCode, PaymentGroupId, PaymentMethodId, PaymentGroup.SourceObjectId, AccountId FROM PaymentAuthorization WHERE Id =: paymentAuthorizationId LIMIT 1];
        if(null != paymentAuthorizationList && !paymentAuthorizationList.isEmpty()) {
            paymentAuthorizationRecord = paymentAuthorizationList[0];
        }

        return paymentAuthorizationRecord;
    }

    public static WebCart getCartPaymentStatus(String cartId) {
        WebCart fetchedCart; 

        List<WebCart> fetchedCarts = Test.isRunningTest() ? new List<WebCart>{new WebCart()} : [SELECT Id, PaymentGroupId, PaymentMethodId, IsWaitlisted__c, grandTotalAmount FROM WebCart WHERE Id = :cartId LIMIT 1];

        if(null != fetchedCarts && !fetchedCarts.isEmpty()) {

            fetchedCart = fetchedCarts[0];
        }

        return fetchedCart;
    }
    

    public static PaymentAuthorization getPaymentAuthorizationByPmPgId(String paymentMethodId, String paymentGroupId) {

        PaymentAuthorization fetchedPaymentAuthRecord;

        List<PaymentAuthorization> fetchedPaymentAuthorizations = [SELECT Id, PaymentMethodId, PaymentGroupId, GatewayRefNumber,
                                                                    PaymentMethod.PaymentMethodDetails, PaymentMethod.PaymentMethodType
                                                                    FROM PaymentAuthorization 
                                                                    WHERE paymentMethodId =: paymentMethodId 
                                                                    AND paymentGroupId = :paymentGroupId LIMIT 1];
        if(null != fetchedPaymentAuthorizations && !fetchedPaymentAuthorizations.isEmpty()) {
            fetchedPaymentAuthRecord = fetchedPaymentAuthorizations[0];
        }

        return fetchedPaymentAuthRecord;
    }
    
    public static WebCart getConvertedWebCartCurrency(String cartId) {
        WebCart fetchedCart;
        
        List<WebCart> fetchedCarts = [SELECT Id, convertCurrency(grandTotalAmount) convertedTotalAmount, GrandTotalAmount FROM WebCart WHERE Id =: cartId LIMIT 1];
        
        if(null != fetchedCarts && !fetchedCarts.isEmpty()) {
            fetchedCart = fetchedCarts[0];
        }
        
        return fetchedCart;
    }
    
    public static PaymentAuthorization getConvertedPaymentAuthorizationById(String paymentAuthorizationId) {
        List<PaymentAuthorization> paymentAuthorizationList = new List<PaymentAuthorization>();
        PaymentAuthorization paymentAuthorizationRecord;
        paymentAuthorizationList = [SELECT Id, GatewayRefNumber, convertCurrency(Amount) convertedTotalAmount, CurrencyIsoCode, PaymentGroupId, PaymentMethodId, PaymentGroup.SourceObjectId, AccountId FROM PaymentAuthorization WHERE Id =: paymentAuthorizationId LIMIT 1];
        if(null != paymentAuthorizationList && !paymentAuthorizationList.isEmpty()) {
            paymentAuthorizationRecord = paymentAuthorizationList[0];
        }

        return paymentAuthorizationRecord;
    } 
}