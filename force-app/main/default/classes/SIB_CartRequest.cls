/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CartRequest extends SIB_BaseRequest {
    @AuraEnabled
    public String cartId{get;set;}

    @AuraEnabled
    public String couponCode{get;set;}

    @AuraEnabled
    public String currencyIsoCode{get;set;}

    @AuraEnabled
    public List<SIB_CartItemRequest> cartItems{get;set;}

    public class SIB_CartItemRequest {

        @AuraEnabled
        public String itemId{get;set;}

        @AuraEnabled
        public String productId{get;set;}

        @AuraEnabled
        public Integer quantity{get;set;}

        @AuraEnabled
        public Decimal unitPrice{get;set;}

    }
    
}