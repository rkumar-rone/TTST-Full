/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 10-13-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CartResponse extends SIB_BaseResponse {
    @AuraEnabled
    public String cartId{get;set;}

    @AuraEnabled
    public String status{get;set;}

    @AuraEnabled
    public Decimal grandTotalAmount{get;set;}

    @AuraEnabled
    public Decimal totalProductAmount{get;set;}

    @AuraEnabled
    public Decimal shippingAmount{get;set;}

    @AuraEnabled
    public Decimal taxAmount{get;set;}

    @AuraEnabled
    public Decimal discountAmount{get;set;}

    @AuraEnabled
    public Integer uniqueProductCount{get;set;}

    @AuraEnabled
    public String currencyIsoCode{get;set;}

    @AuraEnabled
    public Boolean isSuccess{get;set;}

    @AuraEnabled
    public Boolean isLocked{get;set;}

    @AuraEnabled
    public Decimal totalProductAmountAfterAdjustments	{get;set;}

    @AuraEnabled
    public Boolean isGroupOrder {get; set;} //added by Vra 11 Sep 24

    @AuraEnabled
    public List<SIB_CartItemResponse> cartItems{get;set;}

    @AuraEnabled
    public List<ConnectApi.CartItemBasicResult> succeededCartItems{get;set;}

    @AuraEnabled
    public List<ConnectApi.CartItemBasicResult> failedCartItems{get;set;}

    public class SIB_CartItemResponse {

        @AuraEnabled
        public String itemId{get;set;}

        @AuraEnabled
        public String productId{get;set;}

        @AuraEnabled
        public Integer quantity{get;set;}

        @AuraEnabled
        public Decimal unitPrice{get;set;}

        @AuraEnabled
        public Decimal listPrice{get;set;}

        @AuraEnabled
        public Decimal totalPrice{get;set;}

        @AuraEnabled
        public String type{get;set;}

        @AuraEnabled
        public String currencyIsoCode{get;set;}

        @AuraEnabled
        public Decimal totalDiscount{get;set;}

        @AuraEnabled
        public SIB_ProductDetail productDetail{get;set;}

    }
    
}