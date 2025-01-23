/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 10-09-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CheckoutConfiguration {

    @AuraEnabled
    public String id{get;set;}

    @AuraEnabled
    public String displayLayout{get;set;}

    @AuraEnabled
    public List<String> availablePaymentMethods{get;set;}

    @AuraEnabled
    public String creditCardGateway{get;set;}

    @AuraEnabled
    public Map<String,String> creditCardGatewayClassMap{get;set;}

    @AuraEnabled
    public String isShippingProviderEnabled{get;set;}

    @AuraEnabled
    public List<String> shippingProvider{get;set;}

    @AuraEnabled
    public String isTaxProviderEnabled{get;set;}

    @AuraEnabled
    public String taxProvider{get;set;}

    @AuraEnabled
    public Boolean allowPromoCode{get;set;}

    public static SIB_CheckoutConfiguration parse(String json){
        return (SIB_CheckoutConfiguration) System.JSON.deserialize(json, SIB_CheckoutConfiguration.class);
    }
}