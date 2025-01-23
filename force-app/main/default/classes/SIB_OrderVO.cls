/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 03-09-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_OrderVO {
    
    @AuraEnabled
    public String Id{get;set;}
    
    @AuraEnabled
    public String OrderNumber{get;set;}

    @AuraEnabled
    public DateTime OrderedDate{get;set;}

    @AuraEnabled
    public String BillingStreet{get;set;}

    @AuraEnabled
    public String BillingCity{get;set;}

    @AuraEnabled
    public String BillingStateCode{get;set;}

    @AuraEnabled
    public String BillingPostalCode{get;set;}

    @AuraEnabled
    public String BillingCountryCode{get;set;}

    @AuraEnabled
    public String BillingPhoneNumber{get;set;}

    @AuraEnabled
    public String BillingEmailAddress{get;set;}

    @AuraEnabled
    public String BillingName{get;set;}

    @AuraEnabled
    public String PoNumber{get;set;}

    @AuraEnabled
    public String CurrencyIsoCode{get;set;}

    @AuraEnabled
    public Decimal ShippingAmount{get;set;}

    @AuraEnabled
    public String ShippingName{get;set;}

    @AuraEnabled
    public String ShippingStreet{get;set;}

    @AuraEnabled
    public String ShippingCity{get;set;}

    @AuraEnabled
    public String ShippingStateCode{get;set;}

    @AuraEnabled
    public String ShippingPostalCode{get;set;}

    @AuraEnabled
    public String ShippingCountryCode{get;set;}

    @AuraEnabled
    public String ShippingMethod{get;set;}

    @AuraEnabled
    public String clientName{get;set;}

    @AuraEnabled
    public String status{get;set;}

    @AuraEnabled
    public Boolean isPublicCourseExist{get;set;}

    @AuraEnabled
    public Decimal GrandTotalAmount{get;set;}

    @AuraEnabled
    public Decimal TotalTaxAmount{get;set;}

    @AuraEnabled
    public Decimal TotalProductAmount{get;set;}

    @AuraEnabled
    public Decimal OrderAdjustment{get;set;}

    @AuraEnabled
    public String paymentMethod{get;set;}

    @AuraEnabled
    public String paymentSummaryMethodName{get;set;}

    @AuraEnabled
    public List<SIB_OrderItemsVO> orderItems { get; set; }

    public with sharing class SIB_OrderItemsVO {
        @AuraEnabled
        public String Id{get;set;}

        @AuraEnabled
        public String Product2Id{get;set;}

        @AuraEnabled
        public String Name{get;set;}

        @AuraEnabled
        public String ProductImage{get;set;}

        @AuraEnabled
        public Boolean IsSubscriptionProduct{get;set;}

        @AuraEnabled
        public String SKU{get;set;}

        @AuraEnabled
        public Decimal Quantity{get;set;}

        @AuraEnabled
        public Decimal ListPrice{get;set;}

        @AuraEnabled
        public Decimal UnitPrice{get;set;}

        @AuraEnabled
        public Decimal TotalPrice{get;set;}

        @AuraEnabled
        public Decimal AmountSaved{get;set;}

        @AuraEnabled
        public String productSlugURL {get;set;}
    }
}