/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-17-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_ProductPricing extends SIB_BaseResponse{
    
    @AuraEnabled
    public Id pricebookId{get;set;}

    @AuraEnabled
    public Id pricebookEntryId{get;set;}

    @AuraEnabled
    public Id productId{get;set;}

    @AuraEnabled
    public Decimal unitPrice{get;set;}

    @AuraEnabled
    public Decimal listPrice{get;set;}

    @AuraEnabled
    public Decimal negotiatedPrice{get;set;}

    @AuraEnabled
    public Decimal negotiatedPriceDiscount{get;set;}

    @AuraEnabled
    public String negotiatedPriceDiscountPercent{get;set;}

    @AuraEnabled
    public String currencyCode{get;set;}

    @AuraEnabled
    public List<PriceAdjustmentTiers> priceAdjustmentTiers{get;set;}

    public class PriceAdjustmentTiers{

        @AuraEnabled
        public Id adjustmentId{get;set;}

        @AuraEnabled
        public String adjustmentType{get;set;}

        @AuraEnabled
        public Decimal adjustmentValue{get;set;}

        @AuraEnabled
        public Integer lowerBound{get;set;}

        @AuraEnabled
        public Integer upperBound{get;set;}

        @AuraEnabled
        public Decimal tierUnitPrice{get;set;}

    }

    /** TTS Fields */
    @AuraEnabled
    public String displayPrice{get;set;}//Display_Price__c

    @AuraEnabled
    public Decimal earlyBirdSessionPrice{get;set;}//Early_Bird_Session_Price__c

    @AuraEnabled
    public Decimal earlyBirdRegistrationCost{get;set;} //Early_Bird_Registration_Cost_formula__c

    @AuraEnabled
    public Decimal fullRegistrationCost{get;set;}//Full_Registration_Cost_formula__c

    @AuraEnabled
    public String priceLabel{get;set;}

}